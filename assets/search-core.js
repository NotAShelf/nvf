(function (root) {
  const defaultConfig = () => ({
    minWordLength: 2,
    stopwords: [],
    boostTitle: 100.0,
    boostContent: 30.0,
    boostAnchor: 10.0,
  });

  const normalizeConfig = (config) => {
    const defaults = defaultConfig();
    if (!config || typeof config !== "object") return defaults;
    return {
      minWordLength: config.minWordLength ?? defaults.minWordLength,
      stopwords: Array.isArray(config.stopwords)
        ? config.stopwords
        : defaults.stopwords,
      boostTitle: config.boostTitle ?? defaults.boostTitle,
      boostContent: config.boostContent ?? defaults.boostContent,
      boostAnchor: config.boostAnchor ?? defaults.boostAnchor,
    };
  };

  const normalizeSearchText = (text) =>
    (typeof text === "string" ? text : "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, " ")
      .trim()
      .replace(/\s+/g, " ");

  const anchorSearchText = (anchor) =>
    `${anchor?.text || ""} ${anchor?.id || ""}`;

  const tokenizeQuery = (text, config = defaultConfig()) => {
    const searchConfig = normalizeConfig(config);
    const words =
      (typeof text === "string" ? text : "")
        .toLowerCase()
        .match(/\b[a-zA-Z0-9_-]+\b/g) || [];
    const stopwords = new Set(
      searchConfig.stopwords.map((w) => w.toLowerCase()),
    );
    return Array.from(
      new Set(
        words.filter(
          (word) =>
            word.length >= searchConfig.minWordLength && !stopwords.has(word),
        ),
      ),
    );
  };

  const prepareDocuments = (documents) =>
    (Array.isArray(documents) ? documents : []).map((doc, docId) => {
      const title = typeof doc?.title === "string" ? doc.title : "";
      const content = typeof doc?.content === "string" ? doc.content : "";
      const lowerAnchors = Array.isArray(doc?.anchors)
        ? doc.anchors
            .map((anchor) => normalizeSearchText(anchorSearchText(anchor)))
            .join(" ")
        : "";

      return {
        docId,
        doc,
        lowerTitle: title.toLowerCase(),
        lowerContent: content.toLowerCase(),
        lowerAnchors,
      };
    });

  const isWordBoundary = (char) =>
    /[A-Z]/.test(char) || /[-_\/.]/.test(char) || /\s/.test(char);

  const isCaseTransition = (prev, curr) => {
    const prevIsUpper = prev.toLowerCase() !== prev;
    const currIsUpper = curr.toLowerCase() !== curr;
    return (
      prevIsUpper && currIsUpper && prev.toLowerCase() !== curr.toLowerCase()
    );
  };

  const calculateMatchScore = (query, target, positions, consecutive) => {
    const n = positions.length;
    const m = target.length;
    if (n === 0) return 0;

    let score = 1.0;
    score += ((m - positions[0]) / m) * 0.5;

    let gapPenalty = 0;
    for (let i = 1; i < n; i++) {
      const gap = positions[i] - positions[i - 1] - 1;
      if (gap > 0) gapPenalty += Math.min(gap / m, 1.0) * 0.3;
    }
    score -= gapPenalty;
    score += (consecutive / n) * 0.3;

    let boundaryBonus = 0;
    for (let i = 0; i < n; i++) {
      const char = target[positions[i]];
      if (i === 0 || isWordBoundary(char)) boundaryBonus += 0.05;
      if (i > 0 && isCaseTransition(target[positions[i - 1]], char)) {
        boundaryBonus += 0.03;
      }
    }
    score = Math.min(1.0, score + boundaryBonus);

    const lengthPenalty =
      Math.abs(query.length - n) / Math.max(query.length, m);
    score -= lengthPenalty * 0.2;
    return Math.max(0, Math.min(1.0, score));
  };

  const findBestSubsequenceMatch = (query, target) => {
    const n = query.length;
    const m = target.length;
    if (n === 0 || m === 0) return null;

    const positions = [];
    const memo = new Map();
    const key = (qIdx, tIdx, gap) => `${qIdx}:${tIdx}:${gap}`;

    const findBest = (qIdx, tIdx, currentGap) => {
      if (qIdx === n) {
        return { positions: [...positions], gap: currentGap };
      }

      const memoKey = key(qIdx, tIdx, currentGap);
      if (memo.has(memoKey)) return memo.get(memoKey);

      let bestResult = null;
      for (let i = tIdx; i < m; i++) {
        if (target[i] !== query[qIdx]) continue;

        positions.push(i);
        const gap = qIdx === 0 ? 0 : i - positions[positions.length - 2] - 1;
        const newGap = currentGap + gap;
        if (newGap <= m) {
          const result = findBest(qIdx + 1, i + 1, newGap);
          if (result && (!bestResult || result.gap < bestResult.gap)) {
            bestResult = result;
            if (result.gap === 0) {
              positions.pop();
              break;
            }
          }
        }
        positions.pop();
      }

      memo.set(memoKey, bestResult);
      return bestResult;
    };

    const result = findBest(0, 0, 0);
    if (!result) return null;

    let consecutive = 1;
    for (let i = 1; i < result.positions.length; i++) {
      if (result.positions[i] === result.positions[i - 1] + 1) consecutive++;
    }

    return {
      positions: result.positions,
      consecutive,
      score: calculateMatchScore(query, target, result.positions, consecutive),
    };
  };

  const fuzzyMatch = (query, target) => {
    const lowerQuery = query.toLowerCase();
    const lowerTarget = target.toLowerCase();
    if (lowerQuery.length === 0 || lowerTarget.length === 0) return null;
    if (lowerTarget === lowerQuery) return 1.0;
    if (lowerTarget.includes(lowerQuery)) {
      return 0.8 + (lowerQuery.length / lowerTarget.length) * 0.2;
    }

    const match = findBestSubsequenceMatch(lowerQuery, lowerTarget);
    return match ? Math.min(1.0, match.score) : null;
  };

  const isOptionDocument = (doc) =>
    doc?.title?.toLowerCase().startsWith("option: ") ||
    doc?.path?.startsWith("options.html#");

  const textMatchInfo = (text, rawQuery, searchTerms) => {
    const lowerText = typeof text === "string" ? text.toLowerCase() : "";
    const normalizedText = normalizeSearchText(text);
    const normalizedQuery = normalizeSearchText(rawQuery);
    const matchedTerms = searchTerms.filter(
      (term) => lowerText.includes(term) || normalizedText.includes(term),
    );

    return {
      exactText: lowerText === rawQuery || normalizedText === normalizedQuery,
      exactPhrase:
        lowerText.includes(rawQuery) ||
        normalizedText.includes(normalizedQuery),
      matchedTerms,
      allTerms:
        searchTerms.length > 0 && matchedTerms.length === searchTerms.length,
      anyTerm: matchedTerms.length > 0,
    };
  };

  const updateBestRank = (match, rank) => {
    match.bestRank = Math.min(match.bestRank, rank);
  };

  const normalizeForComparison = (text) =>
    (typeof text === "string" ? text : "")
      .toLowerCase()
      .replace(/\s+/g, " ")
      .replace(/[.,!?;:'"…—–-]+$/g, "")
      .trim();

  const documentParagraphs = (doc) =>
    (typeof doc?.content === "string" ? doc.content : "")
      .split("\n")
      .filter((p) => p.trim());

  const findContainingSection = (doc, matchIndex) => {
    if (
      !doc?.content ||
      !Array.isArray(doc.anchors) ||
      doc.anchors.length === 0
    ) {
      return null;
    }

    const paragraphs = documentParagraphs(doc);
    let currentPos = 0;
    let matchParagraphIndex = -1;

    for (let i = 0; i < paragraphs.length; i++) {
      const paragraphEnd = currentPos + paragraphs[i].length;
      if (matchIndex >= currentPos && matchIndex < paragraphEnd) {
        matchParagraphIndex = i;
        break;
      }
      currentPos = paragraphEnd + 1;
    }

    if (matchParagraphIndex === -1) return null;

    let containingAnchor = null;
    for (let i = 0; i <= matchParagraphIndex; i++) {
      const normalizedPara = normalizeForComparison(paragraphs[i].trim());
      const matchingAnchor = doc.anchors.find(
        (a) => normalizeForComparison(a.text) === normalizedPara,
      );
      if (matchingAnchor) containingAnchor = matchingAnchor;
    }
    return containingAnchor;
  };

  const sectionContent = (doc, anchor) => {
    if (!doc?.content || !anchor) return "";

    const paragraphs = documentParagraphs(doc);
    let sectionStart = -1;
    let sectionEnd = paragraphs.length;
    const normalizedAnchor = normalizeForComparison(anchor.text);

    for (let i = 0; i < paragraphs.length; i++) {
      const normalizedPara = normalizeForComparison(paragraphs[i].trim());
      if (normalizedPara === normalizedAnchor) {
        sectionStart = i;
      } else if (
        sectionStart !== -1 &&
        Array.isArray(doc.anchors) &&
        doc.anchors.some(
          (a) => normalizeForComparison(a.text) === normalizedPara,
        )
      ) {
        sectionEnd = i;
        break;
      }
    }

    return sectionStart === -1
      ? ""
      : paragraphs.slice(sectionStart + 1, sectionEnd).join("\n");
  };

  const runSearch = (processedDocs, query, limit, config = defaultConfig()) => {
    const searchConfig = normalizeConfig(config);
    const rawQuery = query.toLowerCase();
    const searchTerms = tokenizeQuery(query, searchConfig);
    const useFuzzySearch = rawQuery.length >= 3;

    if (searchTerms.length === 0 && rawQuery.length < 2) return [];
    if (!Array.isArray(processedDocs) || processedDocs.length === 0) return [];

    const { boostTitle, boostContent, boostAnchor } = searchConfig;
    const normalizedQuery = normalizeSearchText(rawQuery);
    const pageMatches = new Map();

    processedDocs.forEach(
      ({ docId, doc, lowerTitle, lowerContent, lowerAnchors }) => {
        const hasRelevantToken =
          lowerTitle.includes(rawQuery) ||
          lowerContent.includes(rawQuery) ||
          lowerAnchors.includes(normalizedQuery) ||
          searchTerms.some(
            (term) =>
              lowerTitle.includes(term) ||
              lowerContent.includes(term) ||
              lowerAnchors.includes(term),
          );
        if (!hasRelevantToken) return;

        const match = { doc, pageScore: 0, matchingAnchors: [], bestRank: 99 };
        pageMatches.set(docId, match);

        const titleMatch = textMatchInfo(lowerTitle, rawQuery, searchTerms);
        const contentMatch = textMatchInfo(lowerContent, rawQuery, searchTerms);

        if (titleMatch.exactText) {
          match.pageScore += boostTitle * 3;
          updateBestRank(match, isOptionDocument(doc) ? 3 : 0);
        } else if (titleMatch.exactPhrase) {
          match.pageScore += boostTitle * 2;
          updateBestRank(match, isOptionDocument(doc) ? 4 : 1);
        } else if (titleMatch.allTerms) {
          match.pageScore += boostTitle;
          updateBestRank(match, isOptionDocument(doc) ? 5 : 2);
        } else if (titleMatch.anyTerm) {
          match.pageScore += titleMatch.matchedTerms.length * (boostTitle / 10);
          updateBestRank(match, isOptionDocument(doc) ? 8 : 6);
        }

        if (contentMatch.exactPhrase) {
          match.pageScore += boostContent;
          updateBestRank(match, isOptionDocument(doc) ? 9 : 7);
        } else if (contentMatch.allTerms) {
          match.pageScore += boostContent / 2;
          updateBestRank(match, isOptionDocument(doc) ? 10 : 8);
        } else if (contentMatch.anyTerm) {
          match.pageScore +=
            contentMatch.matchedTerms.length * (boostContent / 10);
          updateBestRank(match, isOptionDocument(doc) ? 11 : 9);
        }

        if (
          isOptionDocument(doc) &&
          !titleMatch.exactPhrase &&
          !titleMatch.anyTerm
        ) {
          match.pageScore *= 0.25;
        }
      },
    );

    pageMatches.forEach((match) => {
      const doc = match.doc;
      if (!Array.isArray(doc?.anchors) || doc.anchors.length === 0) return;

      const anchorSet = new Set();
      doc.anchors.forEach((anchor) => {
        if (!anchor?.text) return;

        const anchorText = anchorSearchText(anchor).toLowerCase();
        const anchorMatch = textMatchInfo(anchorText, rawQuery, searchTerms);
        let anchorMatches = anchorMatch.exactPhrase || anchorMatch.allTerms;

        if (!anchorMatches && useFuzzySearch) {
          const fuzzyScore = fuzzyMatch(rawQuery, anchorText);
          anchorMatches = fuzzyScore !== null && fuzzyScore >= 0.8;
        }

        if (!anchorMatches) {
          anchorMatches = searchTerms.some((term) => anchorText.includes(term));
        }

        if (!anchorMatches) return;
        anchorSet.add(anchor.id);

        if (anchorMatch.exactText) {
          match.pageScore += boostTitle * 3;
          updateBestRank(match, 0);
        } else if (anchorMatch.exactPhrase) {
          match.pageScore += boostTitle * 2;
          updateBestRank(match, 1);
        } else if (anchorMatch.allTerms) {
          match.pageScore += boostTitle;
          updateBestRank(match, 2);
        } else {
          match.pageScore += boostAnchor;
          updateBestRank(match, 6);
        }
      });

      if (typeof doc.content === "string") {
        const lowerContent = doc.content.toLowerCase();
        searchTerms.forEach((term) => {
          let searchPos = 0;
          let matchIndex;
          while ((matchIndex = lowerContent.indexOf(term, searchPos)) !== -1) {
            const containingAnchor = findContainingSection(doc, matchIndex);
            if (containingAnchor) anchorSet.add(containingAnchor.id);
            searchPos = matchIndex + term.length;
          }
        });
      }

      doc.anchors.forEach((anchor) => {
        if (anchorSet.has(anchor.id)) match.matchingAnchors.push(anchor);
      });
    });

    return Array.from(pageMatches.values())
      .filter((m) => m.pageScore > 5)
      .sort((a, b) => {
        if (a.bestRank !== b.bestRank) return a.bestRank - b.bestRank;
        if (b.pageScore !== a.pageScore) return b.pageScore - a.pageScore;
        return (
          Number(isOptionDocument(a.doc)) - Number(isOptionDocument(b.doc))
        );
      })
      .slice(0, limit);
  };

  root.searchCore = {
    defaultConfig,
    normalizeConfig,
    normalizeSearchText,
    normalizeForComparison,
    tokenizeQuery,
    prepareDocuments,
    runSearch,
    findContainingSection,
    sectionContent,
  };
})(typeof self !== "undefined" ? self : window);
