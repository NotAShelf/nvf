const isWordBoundary = (char) =>
  /[A-Z]/.test(char) || /[-_\/.]/.test(char) || /\s/.test(char);

const isCaseTransition = (prev, curr) => {
  const prevIsUpper = prev.toLowerCase() !== prev;
  const currIsUpper = curr.toLowerCase() !== curr;
  return (
    prevIsUpper && currIsUpper && prev.toLowerCase() !== curr.toLowerCase()
  );
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
      return { done: true, positions: [...positions], gap: currentGap };
    }

    const memoKey = key(qIdx, tIdx, currentGap);
    if (memo.has(memoKey)) {
      return memo.get(memoKey);
    }

    let bestResult = null;

    for (let i = tIdx; i < m; i++) {
      if (target[i] === query[qIdx]) {
        positions.push(i);
        const gap = qIdx === 0 ? 0 : i - positions[positions.length - 2] - 1;
        const newGap = currentGap + gap;

        if (newGap > m) {
          positions.pop();
          continue;
        }

        const result = findBest(qIdx + 1, i + 1, newGap);
        positions.pop();

        if (result && (!bestResult || result.gap < bestResult.gap)) {
          bestResult = result;
          if (result.gap === 0) break;
        }
      }
    }

    memo.set(memoKey, bestResult);
    return bestResult;
  };

  const result = findBest(0, 0, 0);
  if (!result) return null;

  const consecutive = (() => {
    let c = 1;
    for (let i = 1; i < result.positions.length; i++) {
      if (result.positions[i] === result.positions[i - 1] + 1) {
        c++;
      }
    }
    return c;
  })();

  return {
    positions: result.positions,
    consecutive,
    score: calculateMatchScore(query, target, result.positions, consecutive),
  };
};

const calculateMatchScore = (query, target, positions, consecutive) => {
  const n = positions.length;
  const m = target.length;

  if (n === 0) return 0;

  let score = 1.0;

  const startBonus = (m - positions[0]) / m;
  score += startBonus * 0.5;

  let gapPenalty = 0;
  for (let i = 1; i < n; i++) {
    const gap = positions[i] - positions[i - 1] - 1;
    if (gap > 0) {
      gapPenalty += Math.min(gap / m, 1.0) * 0.3;
    }
  }
  score -= gapPenalty;

  const consecutiveBonus = consecutive / n;
  score += consecutiveBonus * 0.3;

  let boundaryBonus = 0;
  for (let i = 0; i < n; i++) {
    const char = target[positions[i]];
    if (i === 0 || isWordBoundary(char)) {
      boundaryBonus += 0.05;
    }
    if (i > 0) {
      const prevChar = target[positions[i - 1]];
      if (isCaseTransition(prevChar, char)) {
        boundaryBonus += 0.03;
      }
    }
  }
  score = Math.min(1.0, score + boundaryBonus);

  const lengthPenalty = Math.abs(query.length - n) / Math.max(query.length, m);
  score -= lengthPenalty * 0.2;

  return Math.max(0, Math.min(1.0, score));
};

const fuzzyMatch = (query, target) => {
  const lowerQuery = query.toLowerCase();
  const lowerTarget = target.toLowerCase();

  if (lowerQuery.length === 0) return null;
  if (lowerTarget.length === 0) return null;

  if (lowerTarget === lowerQuery) {
    return 1.0;
  }

  if (lowerTarget.includes(lowerQuery)) {
    const ratio = lowerQuery.length / lowerTarget.length;
    return 0.8 + ratio * 0.2;
  }

  const match = findBestSubsequenceMatch(lowerQuery, lowerTarget);
  if (!match) {
    return null;
  }

  return Math.min(1.0, match.score);
};

const isOptionDocument = (doc) =>
  doc?.title?.toLowerCase().startsWith("option: ") ||
  doc?.path?.startsWith("options.html#");

const normalizeSearchText = (text) =>
  (typeof text === "string" ? text : "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");

const anchorSearchText = (anchor) =>
  `${anchor?.text || ""} ${anchor?.id || ""}`;

const textMatchInfo = (text, rawQuery, searchTerms) => {
  const lowerText = typeof text === "string" ? text.toLowerCase() : "";
  const normalizedText = normalizeSearchText(text);
  const normalizedQuery = normalizeSearchText(rawQuery);
  const exactText = lowerText === rawQuery || normalizedText === normalizedQuery;
  const exactPhrase =
    lowerText.includes(rawQuery) || normalizedText.includes(normalizedQuery);
  const matchedTerms = searchTerms.filter(
    (term) => lowerText.includes(term) || normalizedText.includes(term),
  );

  return {
    exactText,
    exactPhrase,
    matchedTerms,
    allTerms:
      searchTerms.length > 0 && matchedTerms.length === searchTerms.length,
    anyTerm: matchedTerms.length > 0,
  };
};

const updateBestRank = (match, rank) => {
  match.bestRank = Math.min(match.bestRank, rank);
};

self.onmessage = function (e) {
  const { messageId, type, data } = e.data;

  const respond = (type, data) => {
    self.postMessage({ messageId, type, data });
  };

  const respondError = (error) => {
    self.postMessage({
      messageId,
      type: "error",
      error: error.message || String(error),
    });
  };

  try {
    if (type === "tokenize") {
      const text = typeof data === "string" ? data : "";
      const words = text.toLowerCase().match(/\b[a-zA-Z0-9_-]+\b/g) || [];
      const tokens = words.filter((word) => word.length > 2);
      const uniqueTokens = Array.from(new Set(tokens));
      respond("tokens", uniqueTokens);
    } else if (type === "search") {
      const { query, limit = 10 } = data;

      if (!query || typeof query !== "string") {
        respond("results", []);
        return;
      }

      const rawQuery = query.toLowerCase();
      const text = typeof query === "string" ? query : "";
      const words = text.toLowerCase().match(/\b[a-zA-Z0-9_-]+\b/g) || [];
      const searchTerms = words.filter((word) => word.length > 2);

      let documents = [];
      if (typeof data.documents === "string") {
        documents = JSON.parse(data.documents);
      } else if (Array.isArray(data.documents)) {
        documents = data.documents;
      } else if (typeof data.transferables === "string") {
        documents = JSON.parse(data.transferables);
      }

      if (!Array.isArray(documents) || documents.length === 0) {
        respond("results", []);
        return;
      }

      const useFuzzySearch = rawQuery.length >= 3;

      if (searchTerms.length === 0 && rawQuery.length < 3) {
        respond("results", []);
        return;
      }

      const pageMatches = new Map();

      // Pre-compute lower-case strings for each document
      const processedDocs = documents.map((doc, docId) => {
        const title = typeof doc.title === "string" ? doc.title : "";
        const content = typeof doc.content === "string" ? doc.content : "";

        return {
          docId,
          doc,
          lowerTitle: title.toLowerCase(),
          lowerContent: content.toLowerCase(),
          lowerAnchors: Array.isArray(doc.anchors)
            ? doc.anchors
                .map((anchor) => normalizeSearchText(anchorSearchText(anchor)))
                .join(" ")
            : "",
        };
      });

      // First pass, only docs containing at least one search term
      processedDocs.forEach(({
        docId,
        doc,
        lowerTitle,
        lowerContent,
        lowerAnchors,
      }) => {
        const normalizedQuery = normalizeSearchText(rawQuery);
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

        let match = pageMatches.get(docId);
        if (!match) {
          match = { doc, pageScore: 0, matchingAnchors: [], bestRank: 99 };
          pageMatches.set(docId, match);
        }

        const titleMatch = textMatchInfo(lowerTitle, rawQuery, searchTerms);
        const contentMatch = textMatchInfo(lowerContent, rawQuery, searchTerms);

        if (titleMatch.exactText) {
          match.pageScore += 300;
          updateBestRank(match, isOptionDocument(doc) ? 3 : 0);
        } else if (titleMatch.exactPhrase) {
          match.pageScore += 200;
          updateBestRank(match, isOptionDocument(doc) ? 4 : 1);
        } else if (titleMatch.allTerms) {
          match.pageScore += 100;
          updateBestRank(match, isOptionDocument(doc) ? 5 : 2);
        } else if (titleMatch.anyTerm) {
          match.pageScore += titleMatch.matchedTerms.length * 10;
          updateBestRank(match, isOptionDocument(doc) ? 8 : 6);
        }

        if (contentMatch.exactPhrase) {
          match.pageScore += 30;
          updateBestRank(match, isOptionDocument(doc) ? 9 : 7);
        } else if (contentMatch.allTerms) {
          match.pageScore += 15;
          updateBestRank(match, isOptionDocument(doc) ? 10 : 8);
        } else if (contentMatch.anyTerm) {
          match.pageScore += contentMatch.matchedTerms.length * 3;
          updateBestRank(match, isOptionDocument(doc) ? 11 : 9);
        }

        if (
          isOptionDocument(doc) &&
          !titleMatch.exactPhrase &&
          !titleMatch.anyTerm
        ) {
          match.pageScore *= 0.25;
        }
      });

      // Second pass: Find matching anchors
      pageMatches.forEach((match) => {
        const doc = match.doc;
        if (
          !doc.anchors ||
          !Array.isArray(doc.anchors) ||
          doc.anchors.length === 0
        ) {
          return;
        }

        doc.anchors.forEach((anchor) => {
          if (!anchor || !anchor.text) return;

          const anchorText = anchorSearchText(anchor).toLowerCase();
          const anchorMatch = textMatchInfo(anchorText, rawQuery, searchTerms);
          let anchorMatches = false;

          if (anchorMatch.exactPhrase || anchorMatch.allTerms) {
            anchorMatches = true;
          } else if (useFuzzySearch) {
            const fuzzyScore = fuzzyMatch(rawQuery, anchorText);
            if (fuzzyScore !== null && fuzzyScore >= 0.8) {
              anchorMatches = true;
            }
          }

          if (!anchorMatches) {
            searchTerms.forEach((term) => {
              if (anchorText.includes(term)) {
                anchorMatches = true;
              }
            });
          }

          if (anchorMatches) {
            match.matchingAnchors.push(anchor);

            if (anchorMatch.exactText) {
              match.pageScore += 300;
              updateBestRank(match, 0);
            } else if (anchorMatch.exactPhrase) {
              match.pageScore += 200;
              updateBestRank(match, 1);
            } else if (anchorMatch.allTerms) {
              match.pageScore += 100;
              updateBestRank(match, 2);
            } else {
              match.pageScore += 10;
              updateBestRank(match, 6);
            }
          }
        });
      });

      const results = Array.from(pageMatches.values())
        .filter((m) => m.pageScore > 5)
        .sort((a, b) => {
          if (a.bestRank !== b.bestRank) return a.bestRank - b.bestRank;
          if (b.pageScore !== a.pageScore) return b.pageScore - a.pageScore;
          return (
            Number(isOptionDocument(a.doc)) - Number(isOptionDocument(b.doc))
          );
        })
        .slice(0, limit);

      respond("results", results);
    }
  } catch (error) {
    respondError(error);
  }
};
