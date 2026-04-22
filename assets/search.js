if (!window.searchNamespace) window.searchNamespace = {};

class SearchEngine {
  // Characters to strip from search term ends for better matching
  static STRIP_TRAILING_CHARS_RE = /[.,!?;:'"…—–-]+$/g;

  constructor() {
    this.documents = [];
    this.tokenMap = new Map();
    this.lowercaseCache = [];
    this.isLoaded = false;
    this.loadError = false;
    this.fullDocuments = null; // for lazy loading
    this.rootPath = window.searchNamespace?.rootPath || "";
    // Search configuration (loaded from search data)
    this.config = {
      minWordLength: 2,
      stopwords: [],
      boostTitle: 100.0,
      boostContent: 30.0,
      boostAnchor: 10.0,
    };
  }

  // Check if we can use Web Worker
  get useWebWorker() {
    if (searchWorker === false) return false; // previously failed
    const worker = initializeSearchWorker();
    return worker !== null;
  }

  // Load search data from JSON
  async loadData() {
    if (this.isLoaded && !this.loadError) return;

    // Clear previous error state on retry
    this.loadError = false;

    try {
      // Load JSON data, try multiple possible paths
      // FIXME: There is only one possible path for now, and this search data is guaranteed
      // to generate at this location, but we'll want to extend this in the future.
      const possiblePaths = [
        `${this.rootPath}assets/search-data.json`,
        "/assets/search-data.json", // fallback for root-level sites
      ];

      let response = null;
      let usedPath = "";

      for (const path of possiblePaths) {
        try {
          const testResponse = await fetch(path);
          if (testResponse.ok) {
            response = testResponse;
            usedPath = path;
            break;
          }
        } catch {
          // Continue to next path
        }
      }

      if (!response) {
        throw new Error("Search data file not found at any expected location");
      }

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const documents = await response.json();
      if (!Array.isArray(documents)) {
        // New format with config
        if (documents.documents && Array.isArray(documents.documents)) {
          this.config = {
            minWordLength: documents.min_word_length || 2,
            stopwords: documents.stopwords || [],
            boostTitle: documents.boost_title || 100.0,
            boostContent: documents.boost_content || 30.0,
            boostAnchor: documents.boost_anchor || 10.0,
          };
          this.initializeFromDocuments(documents.documents);
        } else {
          throw new Error("Invalid search data format");
        }
      } else {
        // Legacy format - just an array of documents
        this.initializeFromDocuments(documents);
      }
      this.isLoaded = true;
    } catch (error) {
      console.error("Error loading search data:", error);
      this.documents = [];
      this.tokenMap.clear();
      this.loadError = true;
    }
  }

  // Initialize from documents array
  async initializeFromDocuments(documents) {
    if (!Array.isArray(documents)) {
      console.error("Invalid documents format:", typeof documents);
      this.documents = [];
    } else {
      this.documents = documents;
    }
    try {
      await this.buildTokenMap();
    } catch (error) {
      console.error("Error building token map:", error);
    }
  }

  // Initialize from search index structure
  initializeIndex(indexData) {
    this.documents = indexData.documents || [];
    this.tokenMap = new Map(Object.entries(indexData.tokenMap || {}));
    this.lowercaseCache = this.documents.map((doc) => ({
      title: (doc.title || "").toLowerCase(),
      content: (doc.content || "").toLowerCase(),
    }));
  }

  // Build token map for faster searching
  buildTokenMap() {
    return new Promise((resolve, reject) => {
      this.tokenMap.clear();

      if (!Array.isArray(this.documents)) {
        console.error("No documents to build token map");
        resolve();
        return;
      }

      const totalDocs = this.documents.length;
      let processedDocs = 0;

      this.lowercaseCache = [];

      try {
        // Process in chunks to avoid blocking UI
        const processChunk = (startIndex, chunkSize) => {
          try {
            const endIndex = Math.min(startIndex + chunkSize, totalDocs);

            for (let i = startIndex; i < endIndex; i++) {
              const doc = this.documents[i];
              if (
                !doc ||
                typeof doc.title !== "string" ||
                typeof doc.content !== "string"
              ) {
                console.warn(`Invalid document at index ${i}:`, doc);
                continue;
              }

              const lowerTitle = doc.title.toLowerCase();
              const lowerContent = doc.content.toLowerCase();
              this.lowercaseCache[i] = {
                title: lowerTitle,
                content: lowerContent,
              };

              const tokens = this.tokenize(lowerTitle + " " + lowerContent);
              tokens.forEach((token) => {
                if (!this.tokenMap.has(token)) {
                  this.tokenMap.set(token, []);
                }
                this.tokenMap.get(token).push(i);
              });

              processedDocs++;
            }

            // Update progress and yield control
            if (endIndex < totalDocs) {
              setTimeout(() => processChunk(endIndex, chunkSize), 0);
            } else {
              resolve();
            }
          } catch (error) {
            reject(error);
          }
        };

        // Start processing with small chunks
        processChunk(0, 100);
      } catch (error) {
        reject(error);
      }
    });
  }

  isWordBoundary(char) {
    return /[A-Z]/.test(char) || /[-_\/.]/.test(char) || /\s/.test(char);
  }

  isCaseTransition(prev, curr) {
    const prevIsUpper = prev.toLowerCase() !== prev;
    const currIsUpper = curr.toLowerCase() !== curr;
    return (
      prevIsUpper && currIsUpper && prev.toLowerCase() !== curr.toLowerCase()
    );
  }

  fuzzyMatch(query, target) {
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

    const matches = this.findBestSubsequenceMatch(lowerQuery, lowerTarget);
    if (!matches) {
      return null;
    }

    return Math.min(1.0, matches.score);
  }

  findBestSubsequenceMatch(query, target) {
    const n = query.length;
    const m = target.length;

    if (n === 0 || m === 0) return null;

    const positions = [];

    const memo = new Map();
    const key = (qIdx, tIdx) => `${qIdx}:${tIdx}`;

    const findBest = (qIdx, tIdx, currentGap) => {
      if (qIdx === n) {
        return { done: true, positions: [...positions], gap: currentGap };
      }

      const memoKey = key(qIdx, tIdx);
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
      score: this.calculateMatchScore(
        query,
        target,
        result.positions,
        consecutive,
      ),
    };
  }

  calculateMatchScore(query, target, positions, consecutive) {
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
      if (i === 0 || this.isWordBoundary(char)) {
        boundaryBonus += 0.05;
      }
      if (i > 0) {
        const prevChar = target[positions[i - 1]];
        if (this.isCaseTransition(prevChar, char)) {
          boundaryBonus += 0.03;
        }
      }
    }
    score = Math.min(1.0, score + boundaryBonus);

    const lengthPenalty =
      Math.abs(query.length - n) / Math.max(query.length, m);
    score -= lengthPenalty * 0.2;

    return Math.max(0, Math.min(1.0, score));
  }

  tokenize(text) {
    if (!text || typeof text !== "string") return [];

    const words = text.toLowerCase().match(/\b[a-zA-Z0-9_-]+\b/g) || [];
    const stopwordsSet = new Set(
      this.config.stopwords.map((w) => w.toLowerCase()),
    );
    const tokens = words.filter(
      (word) =>
        word.length >= this.config.minWordLength && !stopwordsSet.has(word),
    );
    return Array.from(new Set(tokens));
  }

  // Advanced search with ranking
  async search(query, limit = 10, options = {}) {
    if (!query || typeof query !== "string" || !query.trim()) {
      return [];
    }

    if (options.signal?.aborted) {
      return [];
    }

    // Wait for data to be loaded
    if (!this.isLoaded) {
      await this.loadData();
    }

    if (options.signal?.aborted) {
      return [];
    }

    if (!this.isLoaded || this.documents.length === 0) {
      return [];
    }

    const searchTerms = this.tokenize(query);
    const rawQuery = query.toLowerCase();

    // Require at least 2 characters for search
    if (searchTerms.length === 0 && rawQuery.length < 2) {
      return [];
    }

    const useFuzzySearch = rawQuery.length >= 3;

    const candidateDocIds = new Set();
    searchTerms.forEach((term) => {
      if (this.tokenMap.has(term)) {
        const docIds = this.tokenMap.get(term);
        docIds.forEach((docId) => candidateDocIds.add(docId));
      }
    });

    if (candidateDocIds.size === 0) {
      return [];
    }

    const pageMatches = new Map();
    let lastCheckTime = Date.now();
    const CHECK_INTERVAL = 16; // Check every ~16ms (one frame)

    for (const docIdx of candidateDocIds) {
      // Check for abort periodically
      if (Date.now() - lastCheckTime > CHECK_INTERVAL) {
        if (options.signal?.aborted) {
          return [];
        }
        // Yield to main thread
        await new Promise((resolve) => setTimeout(resolve, 0));
        lastCheckTime = Date.now();

        if (options.signal?.aborted) {
          return [];
        }
      }

      const doc = this.documents[docIdx];
      let match = pageMatches.get(docIdx);
      if (!match) {
        match = { doc, pageScore: 0, matchingAnchors: [] };
        pageMatches.set(docIdx, match);
      }

      const cached = this.lowercaseCache?.[docIdx];
      const lowerTitle =
        cached?.title ??
        (typeof doc.title === "string" ? doc.title : "").toLowerCase();
      const lowerContent =
        cached?.content ??
        (typeof doc.content === "string" ? doc.content : "").toLowerCase();

      if (useFuzzySearch) {
        const fuzzyTitleScore = this.fuzzyMatch(rawQuery, lowerTitle);

        if (fuzzyTitleScore !== null) {
          match.pageScore += fuzzyTitleScore * this.config.boostTitle;
        }

        const fuzzyContentScore = this.fuzzyMatch(rawQuery, lowerContent);

        if (fuzzyContentScore !== null) {
          match.pageScore += fuzzyContentScore * this.config.boostContent;
        }
      }

      searchTerms.forEach((term) => {
        if (lowerTitle.includes(term)) {
          match.pageScore +=
            lowerTitle === term
              ? this.config.boostTitle / 5
              : this.config.boostTitle / 10;
        }
        if (lowerContent.includes(term)) {
          match.pageScore += this.config.boostContent / 15;
        }
      });
    }

    if (options.signal?.aborted) {
      return [];
    }

    pageMatches.forEach((match) => {
      const doc = match.doc;
      if (
        !doc.anchors ||
        !Array.isArray(doc.anchors) ||
        doc.anchors.length === 0
      ) {
        return;
      }

      const anchorSet = new Set();

      // Check for anchor text matches
      doc.anchors.forEach((anchor) => {
        if (!anchor || !anchor.text) return;

        const anchorText = anchor.text.toLowerCase();
        let anchorMatches = false;

        if (useFuzzySearch) {
          const fuzzyScore = this.fuzzyMatch(rawQuery, anchorText);
          if (fuzzyScore !== null && fuzzyScore >= 0.4) {
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
          anchorSet.add(anchor.id);
        }
      });

      // Check for content matches and find their containing sections
      if (doc.content && typeof doc.content === "string") {
        const lowerContent = doc.content.toLowerCase();

        searchTerms.forEach((term) => {
          let searchPos = 0;
          let matchIndex;

          while ((matchIndex = lowerContent.indexOf(term, searchPos)) !== -1) {
            const containingAnchor = this.findContainingSection(
              doc,
              matchIndex,
            );
            if (containingAnchor && !anchorSet.has(containingAnchor.id)) {
              anchorSet.add(containingAnchor.id);
            }
            searchPos = matchIndex + term.length;
          }
        });
      }

      // Convert set back to anchor objects
      doc.anchors.forEach((anchor) => {
        if (anchorSet.has(anchor.id)) {
          match.matchingAnchors.push(anchor);
        }
      });
    });

    const results = Array.from(pageMatches.values())
      .filter((m) => m.pageScore > 5)
      .sort((a, b) => b.pageScore - a.pageScore)
      .slice(0, limit);

    return results;
  }

  // Generate search preview with highlighting
  generatePreview(content, query, maxLength = 200) {
    if (!content || typeof content !== "string") {
      return "";
    }

    const lowerContent = content.toLowerCase();
    const queryWords = this.tokenize(query);

    // Find the best match position
    let bestIndex = -1;
    let bestMatch = "";

    for (const word of queryWords) {
      const index = lowerContent.indexOf(word);
      if (index !== -1 && word.length > bestMatch.length) {
        bestIndex = index;
        bestMatch = word;
      }
    }

    // If no match found, show beginning
    if (bestIndex === -1) {
      const preview = content.slice(0, maxLength).trim();
      const escaped = this.escapeHtml(preview);
      return escaped + (content.length > maxLength ? "..." : "");
    }

    // Find paragraph boundaries around the match
    const paragraphs = content.split("\n").filter((p) => p.trim());
    let currentPos = 0;
    let matchParagraphIndex = -1;

    for (let i = 0; i < paragraphs.length; i++) {
      const paragraphEnd = currentPos + paragraphs[i].length;
      if (bestIndex >= currentPos && bestIndex < paragraphEnd) {
        matchParagraphIndex = i;
        break;
      }
      currentPos = paragraphEnd + 1;
    }

    if (matchParagraphIndex === -1) {
      matchParagraphIndex = 0;
    }

    // If matching paragraph is very short (likely a title/heading),
    // prefer showing the next paragraph if it also contains the search term
    if (
      matchParagraphIndex < paragraphs.length - 1 &&
      paragraphs[matchParagraphIndex].length < 50
    ) {
      const nextParagraph = paragraphs[matchParagraphIndex + 1];
      if (nextParagraph.toLowerCase().includes(bestMatch)) {
        matchParagraphIndex++;
      }
    }

    // Get the matching paragraph
    let preview = paragraphs[matchParagraphIndex];

    // If paragraph is too long, extract context around match
    if (preview.length > maxLength) {
      const matchInParagraph = preview.toLowerCase().indexOf(bestMatch);
      if (matchInParagraph !== -1) {
        const contextBefore = 60;
        const contextAfter = 100;
        const start = Math.max(0, matchInParagraph - contextBefore);
        const end = Math.min(
          preview.length,
          matchInParagraph + bestMatch.length + contextAfter,
        );
        preview = preview.slice(start, end).trim();
        if (start > 0) preview = "..." + preview;
        if (end < paragraphs[matchParagraphIndex].length) preview += "...";
      } else {
        preview = preview.slice(0, maxLength) + "...";
      }
    }

    return this.escapeHtml(preview);
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    if (!text || typeof text !== "string") return "";

    const escapeMap = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#x27;",
      "/": "&#x2F;",
    };

    return text.replace(/[&<>"'\/]/g, (char) => escapeMap[char]);
  }

  // Highlight search terms in text
  highlightTerms(text, terms) {
    if (!text || typeof text !== "string") return "";
    if (!Array.isArray(terms) || terms.length === 0) {
      return this.escapeHtml(text);
    }

    // Escape HTML first
    let highlighted = this.escapeHtml(text);

    // Sort terms by length (longer first) to avoid overlapping highlights
    const sortedTerms = [...terms].sort((a, b) => b.length - a.length);

    sortedTerms.forEach((term) => {
      if (!term || typeof term !== "string") return;
      const regex = new RegExp(`(${this.escapeRegex(term)})`, "gi");
      highlighted = highlighted.replace(regex, "<mark>$1</mark>");
    });

    return highlighted;
  }

  /**
   * Web Worker search for large datasets
   * @param {string} query - Search query
   * @param {number} limit - Maximum results
   * @returns {Promise<Array>} Search results
   */
  searchWithWorker(query, limit) {
    const worker = initializeSearchWorker();
    if (!worker) {
      return this.fallbackSearch(query, limit);
    }

    return new Promise((resolve, reject) => {
      const messageId = `search_${Date.now()}_${Math.random()
        .toString(36)
        .substring(2, 11)}`;
      const timeout = setTimeout(() => {
        cleanup();
        reject(new Error("Web Worker search timeout"));
      }, 5000);

      const handleMessage = (e) => {
        if (e.data.messageId !== messageId) return;

        clearTimeout(timeout);
        cleanup();

        if (e.data.type === "results") {
          resolve(e.data.data);
        } else if (e.data.type === "error") {
          reject(new Error(e.data.error || "Unknown worker error"));
        }
      };

      const handleError = (error) => {
        clearTimeout(timeout);
        cleanup();
        reject(error);
      };

      const cleanup = () => {
        worker.removeEventListener("message", handleMessage);
        worker.removeEventListener("error", handleError);
      };

      worker.addEventListener("message", handleMessage);
      worker.addEventListener("error", handleError);

      worker.postMessage({
        messageId,
        type: "search",
        data: { query, limit },
        documents: this.documents,
      });
    });
  }

  // Normalize text for comparison
  normalizeForComparison(text) {
    if (!text || typeof text !== "string") return "";
    return text
      .toLowerCase()
      .replace(/\s+/g, " ")
      .replace(SearchEngine.STRIP_TRAILING_CHARS_RE, "")
      .trim();
  }

  // Find which section/heading a content match belongs to
  findContainingSection(doc, matchIndex) {
    if (!doc.content || !doc.anchors || doc.anchors.length === 0) {
      return null;
    }

    const paragraphs = doc.content.split("\n").filter((p) => p.trim());

    // Find which paragraph contains the match
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

    if (matchParagraphIndex === -1) {
      return null;
    }

    // Find the last heading that appears before this paragraph
    let containingAnchor = null;

    for (let i = 0; i <= matchParagraphIndex; i++) {
      const para = paragraphs[i].trim();
      const matchingAnchor = doc.anchors.find((a) => {
        const normalizedAnchor = this.normalizeForComparison(a.text);
        const normalizedPara = this.normalizeForComparison(para);
        return normalizedAnchor === normalizedPara;
      });

      if (matchingAnchor) {
        containingAnchor = matchingAnchor;
      }
    }

    return containingAnchor;
  }

  // Generate preview for a specific section
  generateSectionPreview(doc, anchor, query, maxLength = 200) {
    if (!doc.content || !anchor) {
      return "";
    }

    const paragraphs = doc.content.split("\n").filter((p) => p.trim());

    // Find where this section starts and ends
    let sectionStart = -1;
    let sectionEnd = paragraphs.length;

    for (let i = 0; i < paragraphs.length; i++) {
      const para = paragraphs[i].trim();
      const normalizedPara = this.normalizeForComparison(para);
      const normalizedAnchor = this.normalizeForComparison(anchor.text);

      if (normalizedPara === normalizedAnchor) {
        sectionStart = i;
      } else if (sectionStart !== -1 && doc.anchors) {
        // Check if this is another heading
        const isHeading = doc.anchors.some((a) => {
          const norm = this.normalizeForComparison(a.text);
          return norm === normalizedPara;
        });

        if (isHeading) {
          sectionEnd = i;
          break;
        }
      }
    }

    if (sectionStart === -1) {
      return "";
    }

    // Get content of this section (excluding the heading itself)
    const sectionParagraphs = paragraphs.slice(sectionStart + 1, sectionEnd);
    const sectionContent = sectionParagraphs.join("\n");

    // Use existing generatePreview on just this section's content
    return this.generatePreview(sectionContent, query, maxLength);
  }

  // Escape regex special characters
  escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  // Resolve path relative to current page location
  resolvePath(path) {
    // If path already starts with '/', it's absolute from domain root
    if (path.startsWith("/")) {
      return path;
    }

    // If path starts with '#', it's a fragment on current page
    if (path.startsWith("#")) {
      return path;
    }

    // Prepend root path for relative navigation
    return this.rootPath + path;
  }

  // Lazy loading for search results
  lazyLoadDocuments(docIds, limit = 10) {
    if (!this.fullDocuments) {
      // Store full documents separately for memory efficiency
      this.fullDocuments = this.documents;
      // Create lightweight index documents
      this.documents = this.documents.map((doc) => ({
        id: doc.id,
        title: doc.title,
        path: doc.path,
      }));
    }

    return docIds.slice(0, limit).map((id) => this.fullDocuments[id]);
  }

  // Fallback search method via simple string matching
  fallbackSearch(query, limit = 10) {
    if (!query || typeof query !== "string") return [];

    const lowerQuery = query.toLowerCase();
    if (lowerQuery.length < 2) return [];

    const results = this.documents
      .map((doc) => {
        if (!doc || !doc.title || !doc.content) {
          return null;
        }

        const titleMatch = doc.title.toLowerCase().indexOf(lowerQuery);
        const contentMatch = doc.content.toLowerCase().indexOf(lowerQuery);
        let pageScore = 0;

        if (titleMatch !== -1) {
          pageScore += this.config.boostTitle / 10;
          if (doc.title.toLowerCase() === lowerQuery) {
            pageScore += this.config.boostTitle / 5;
          }
        }
        if (contentMatch !== -1) {
          pageScore += this.config.boostContent / 15;
        }

        // Find matching anchors
        const matchingAnchors = [];
        if (
          doc.anchors &&
          Array.isArray(doc.anchors) &&
          doc.anchors.length > 0
        ) {
          doc.anchors.forEach((anchor) => {
            if (!anchor || !anchor.text) return;
            const anchorText = anchor.text.toLowerCase();
            if (anchorText.includes(lowerQuery)) {
              matchingAnchors.push(anchor);
            }
          });
        }

        return { doc, pageScore, matchingAnchors, titleMatch, contentMatch };
      })
      .filter((item) => item !== null && item.pageScore > 0)
      .sort((a, b) => {
        if (a.pageScore !== b.pageScore) return b.pageScore - a.pageScore;
        if (a.titleMatch !== b.titleMatch) return a.titleMatch - b.titleMatch;
        return a.contentMatch - b.contentMatch;
      })
      .slice(0, limit);

    return results;
  }
}

// Web Worker for background search processing
// Create Web Worker if supported - initialized lazily to use rootPath
let searchWorker = null;

// Keyboard navigation helper class
class SearchKeyboardNav {
  constructor(container, selector) {
    this.container = container;
    this.selector = selector;
    this.activeIndex = -1;
    this.items = [];
    this.navigationPending = false;
  }

  updateItems() {
    this.items = Array.from(this.container.querySelectorAll(this.selector));
    if (this.activeIndex >= this.items.length) {
      this.activeIndex = -1;
    }
  }

  clear() {
    this.setActive(-1);
    this.items = [];
  }

  setActive(index) {
    // Remove active class from previous item
    if (this.activeIndex >= 0 && this.activeIndex < this.items.length) {
      this.items[this.activeIndex].classList.remove("search-result-active");
    }

    this.activeIndex = index;

    // Add active class to new item
    if (this.activeIndex >= 0 && this.activeIndex < this.items.length) {
      this.items[this.activeIndex].classList.add("search-result-active");
      this.items[this.activeIndex].scrollIntoView({
        block: "nearest",
        behavior: "smooth",
      });
    }
  }

  moveDown() {
    if (this.items.length === 0) return;
    const newIndex = Math.min(this.activeIndex + 1, this.items.length - 1);
    this.setActive(newIndex);
  }

  moveUp() {
    if (this.items.length === 0) return;
    const newIndex = Math.max(this.activeIndex - 1, -1);
    this.setActive(newIndex);
  }

  moveToFirst() {
    if (this.items.length === 0) return;
    this.setActive(0);
  }

  moveToLast() {
    if (this.items.length === 0) return;
    this.setActive(this.items.length - 1);
  }

  select() {
    // Guard against double-navigation
    if (this.navigationPending) return false;

    if (this.activeIndex >= 0 && this.activeIndex < this.items.length) {
      const link = this.items[this.activeIndex].querySelector("a");
      if (link) {
        this.navigationPending = true;

        // Add search query to URL if it's a result link
        const currentQuery =
          this.container.closest(".search-container")?.querySelector("input")
            ?.value || document.getElementById("search-page-input")?.value;
        if (currentQuery) {
          const url = new URL(link.href, window.location.origin);
          url.searchParams.set("highlight", currentQuery);

          // Clear flag after navigation starts
          setTimeout(() => {
            this.navigationPending = false;
          }, 100);

          window.location.href = url.toString();
        } else {
          // Clear flag before click to allow navigation
          setTimeout(() => {
            this.navigationPending = false;
          }, 100);
          link.click();
        }
        return true;
      }
    }
    return false;
  }
}

function debounce(func, wait) {
  let timeout = null;
  return function (...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
  };
}

function initializeSearchWorker() {
  if (searchWorker !== null || typeof Worker === "undefined") {
    return searchWorker;
  }

  try {
    const rootPath = window.searchNamespace?.rootPath || "";
    const workerPath = rootPath
      ? `${rootPath}assets/search-worker.js`
      : "/assets/search-worker.js";
    searchWorker = new Worker(workerPath);
    return searchWorker;
  } catch (error) {
    console.warn("Web Worker creation failed, using main thread:", error);
    searchWorker = false; // mark as failed so we don't retry
    return null;
  }
}

// Global search engine instance
window.searchNamespace.engine = new SearchEngine();

// Mobile search timeout for debouncing
let mobileSearchTimeout = null;

// AbortController for cancelling pending search requests
let searchPageController = null;

document.addEventListener("DOMContentLoaded", function () {
  // Initialize search engine immediately
  window.searchNamespace.engine
    .loadData()
    .then(() => {})
    .catch((error) => {
      console.error("Failed to initialize search:", error);
    });

  // Search page specific functionality
  const searchPageInput = document.getElementById("search-page-input");
  if (searchPageInput) {
    // Initialize keyboard navigation for search page
    const searchPageResults = document.getElementById("search-page-results");
    const searchPageKeyboardNav = new SearchKeyboardNav(
      searchPageResults,
      ".search-result-item",
    );

    // Keyboard navigation for search page
    searchPageInput.addEventListener("keydown", function (event) {
      const hasResults =
        searchPageResults &&
        searchPageResults.querySelector(".search-result-item");

      if (!hasResults) return;

      if (event.key === "ArrowDown") {
        event.preventDefault();
        searchPageKeyboardNav.moveDown();
      } else if (event.key === "ArrowUp") {
        event.preventDefault();
        searchPageKeyboardNav.moveUp();
      } else if (event.key === "Home") {
        event.preventDefault();
        searchPageKeyboardNav.moveToFirst();
      } else if (event.key === "End") {
        event.preventDefault();
        searchPageKeyboardNav.moveToLast();
      } else if (
        event.key === "Enter" &&
        searchPageKeyboardNav.activeIndex >= 0
      ) {
        event.preventDefault();
        searchPageKeyboardNav.select();
      } else if (event.key === "Escape") {
        event.preventDefault();
        searchPageKeyboardNav.clear();
        searchPageInput.blur();
      }
    });

    // Set up event listener with debouncing
    searchPageInput.addEventListener(
      "input",
      debounce(function () {
        const query = this.value.trim();
        if (query.length >= 2) {
          performSearch(query, searchPageKeyboardNav);
        } else {
          const resultsContainer = document.getElementById(
            "search-page-results",
          );
          if (resultsContainer) {
            resultsContainer.innerHTML =
              "<p>Please enter at least 2 characters to search</p>";
          }
          searchPageKeyboardNav.clear();
        }
      }, 200),
    );

    // Perform search if URL has query
    const params = new URLSearchParams(window.location.search);
    const query = params.get("q");
    if (query) {
      searchPageInput.value = query;
      performSearch(query, searchPageKeyboardNav);
    }
  }

  // Desktop Sidebar Toggle
  const searchInput = document.getElementById("search-input");
  if (searchInput) {
    const searchResults = document.getElementById("search-results");
    const searchContainer = searchInput.closest(".search-container");
    // Initialize keyboard navigation for desktop search
    const desktopKeyboardNav = new SearchKeyboardNav(
      searchResults,
      ".search-result-item",
    );

    searchInput.addEventListener(
      "input",
      debounce(async function () {
        const searchTerm = this.value.trim();
        const currentSearchTerm = searchTerm;

        if (searchTerm.length < 2) {
          searchResults.innerHTML = "";
          searchResults.style.display = "none";
          if (searchContainer) searchContainer.classList.remove("has-results");
          desktopKeyboardNav.clear();
          return;
        }

        searchResults.innerHTML =
          '<div class="search-result-item">Loading...</div>';
        searchResults.style.display = "block";
        if (searchContainer) searchContainer.classList.add("has-results");

        try {
          const results = await window.searchNamespace.engine.search(
            searchTerm,
            8,
          );

          if (currentSearchTerm !== searchTerm) return;

          if (results.length > 0) {
            searchResults.innerHTML = results
              .map((result) => {
                const { doc, matchingAnchors } = result;
                const queryTerms =
                  window.searchNamespace.engine.tokenize(searchTerm);
                const highlightedTitle =
                  window.searchNamespace.engine.highlightTerms(
                    doc.title,
                    queryTerms,
                  );
                const resolvedPath = window.searchNamespace.engine.resolvePath(
                  doc.path,
                );

                let html = `
                <div class="search-result-item search-result-page">
                  <a href="${resolvedPath}">${highlightedTitle}</a>
                </div>
              `;

                if (matchingAnchors && matchingAnchors.length > 0) {
                  matchingAnchors.forEach((anchor) => {
                    // Skip anchors that duplicate the page title
                    const normalizedAnchor =
                      window.searchNamespace.engine.normalizeForComparison(
                        anchor.text,
                      );
                    const normalizedTitle =
                      window.searchNamespace.engine.normalizeForComparison(
                        doc.title,
                      );
                    if (normalizedAnchor === normalizedTitle) {
                      return;
                    }

                    const highlightedAnchor =
                      window.searchNamespace.engine.highlightTerms(
                        anchor.text,
                        queryTerms,
                      );
                    const anchorPath = `${resolvedPath}#${anchor.id}`;
                    html += `
                    <div class="search-result-item search-result-anchor">
                      <a href="${anchorPath}">${highlightedAnchor}</a>
                    </div>
                  `;
                  });
                }

                return html;
              })
              .join("");
            searchResults.style.display = "block";
            if (searchContainer) searchContainer.classList.add("has-results");
            desktopKeyboardNav.updateItems();
          } else {
            searchResults.innerHTML =
              '<div class="search-result-item">No results found</div>';
            searchResults.style.display = "block";
            if (searchContainer) searchContainer.classList.add("has-results");
          }
        } catch (error) {
          console.error("Search error:", error);
          searchResults.innerHTML =
            '<div class="search-result-item search-error" role="alert">Search unavailable. <a href="#" onclick="event.preventDefault(); window.searchNamespace.engine.loadData();">Retry</a></div>';
          searchResults.style.display = "block";
          if (searchContainer) searchContainer.classList.add("has-results");
        }
      }, 150),
    );

    // Hide results when clicking outside
    document.addEventListener("click", function (event) {
      if (
        !searchInput.contains(event.target) &&
        !searchResults.contains(event.target)
      ) {
        searchResults.style.display = "none";
        if (searchContainer) searchContainer.classList.remove("has-results");
        desktopKeyboardNav.clear();
      }
    });

    // Keyboard navigation for desktop search
    searchInput.addEventListener("keydown", function (event) {
      if (searchResults.style.display !== "block") return;

      if (event.key === "ArrowDown") {
        event.preventDefault();
        desktopKeyboardNav.moveDown();
      } else if (event.key === "ArrowUp") {
        event.preventDefault();
        desktopKeyboardNav.moveUp();
      } else if (event.key === "Home") {
        event.preventDefault();
        desktopKeyboardNav.moveToFirst();
      } else if (event.key === "End") {
        event.preventDefault();
        desktopKeyboardNav.moveToLast();
      } else if (event.key === "Enter" && desktopKeyboardNav.activeIndex >= 0) {
        event.preventDefault();
        desktopKeyboardNav.select();
      } else if (event.key === "Escape") {
        event.preventDefault();
        searchResults.style.display = "none";
        if (searchContainer) searchContainer.classList.remove("has-results");
        desktopKeyboardNav.clear();
        searchInput.blur();
      }
    });

    // Focus search when pressing slash key
    document.addEventListener("keydown", function (event) {
      if (event.key === "/" && document.activeElement !== searchInput) {
        event.preventDefault();
        searchInput.focus();
      }
    });

    setupDocumentEventHandlers(searchInput, searchResults, searchContainer);
  }

  function setupDocumentEventHandlers(
    searchInput,
    searchResults,
    searchContainer,
  ) {
    document.addEventListener("click", function (event) {
      const isMobileSearchActive =
        mobileSearchPopup && mobileSearchPopup.classList.contains("active");
      const isDesktopResultsVisible = searchResults.style.display === "block";

      if (
        isMobileSearchActive &&
        !mobileSearchPopup.contains(event.target) &&
        !searchInput.contains(event.target)
      ) {
        closeMobileSearch();
      }

      if (
        isDesktopResultsVisible &&
        !searchInput.contains(event.target) &&
        !searchResults.contains(event.target)
      ) {
        searchResults.style.display = "none";
        if (searchContainer) searchContainer.classList.remove("has-results");
      }
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "/" && document.activeElement !== searchInput) {
        event.preventDefault();
        searchInput.focus();
      }

      if (
        event.key === "Escape" &&
        (document.activeElement === searchInput ||
          searchResults.style.display === "block")
      ) {
        searchResults.style.display = "none";
        if (searchContainer) searchContainer.classList.remove("has-results");
        searchInput.blur();
      }

      if (
        event.key === "Escape" &&
        mobileSearchPopup &&
        mobileSearchPopup.classList.contains("active")
      ) {
        closeMobileSearch();
      }
    });
  }

  // Mobile search functionality
  // This detects mobile viewport and adds click behavior
  function isMobile() {
    return window.innerWidth <= 800;
  }

  if (searchInput) {
    // Add mobile search behavior
    searchInput.addEventListener("click", function (e) {
      if (isMobile()) {
        e.preventDefault();
        e.stopPropagation();
        openMobileSearch();
      }
      // On desktop, we let the normal click behavior work (focus the input)
    });

    // Prevent typing on mobile (input should only open popup)
    searchInput.addEventListener("keydown", function (e) {
      if (isMobile()) {
        e.preventDefault();
        openMobileSearch();
      }
    });
  }

  // Mobile search popup functionality
  const mobileSearchPopup = document.getElementById("mobile-search-popup");
  const mobileSearchInput = document.getElementById("mobile-search-input");
  const mobileSearchResults = document.getElementById("mobile-search-results");
  const closeMobileSearchBtn = document.getElementById("close-mobile-search");

  // Store cleanup function to prevent memory leaks
  let mobileFocusTrapCleanup = null;

  function setupMobileFocusTrap() {
    if (!mobileSearchPopup || !mobileSearchPopup.classList.contains("active")) {
      return;
    }

    const focusableElements = [
      mobileSearchInput,
      closeMobileSearchBtn,
      ...Array.from(mobileSearchResults.querySelectorAll("a[href]")),
    ].filter((el) => el !== null);

    if (focusableElements.length === 0) return;

    const firstFocusable = focusableElements[0];
    const lastFocusable = focusableElements[focusableElements.length - 1];

    const handleKeyDown = (e) => {
      if (e.key === "Tab") {
        if (e.shiftKey && document.activeElement === firstFocusable) {
          e.preventDefault();
          lastFocusable.focus();
        } else if (!e.shiftKey && document.activeElement === lastFocusable) {
          e.preventDefault();
          firstFocusable.focus();
        }
      }

      if (e.key === "Escape") {
        closeMobileSearch();
      }

      // Arrow key navigation in results
      if (["ArrowDown", "ArrowUp"].includes(e.key)) {
        const links = Array.from(
          mobileSearchResults.querySelectorAll("a[href]"),
        );
        if (links.length === 0) return;

        const currentIndex = links.indexOf(document.activeElement);

        if (e.key === "ArrowDown") {
          e.preventDefault();
          if (currentIndex === -1) {
            links[0].focus();
          } else {
            const nextIndex = Math.min(currentIndex + 1, links.length - 1);
            links[nextIndex].focus();
          }
        } else if (e.key === "ArrowUp") {
          e.preventDefault();
          if (currentIndex > 0) {
            links[currentIndex - 1].focus();
          } else if (currentIndex === 0) {
            mobileSearchInput.focus();
          }
        }
      }
    };

    mobileSearchPopup.addEventListener("keydown", handleKeyDown);

    // Return cleanup function
    return () => {
      mobileSearchPopup.removeEventListener("keydown", handleKeyDown);
    };
  }

  function openMobileSearch() {
    if (mobileSearchPopup) {
      mobileSearchPopup.classList.add("active");
      // Focus the input after a small delay to ensure the popup is visible
      setTimeout(() => {
        if (mobileSearchInput) {
          mobileSearchInput.focus();
        }
        // Clean up previous session's listeners before setting up new ones
        if (mobileFocusTrapCleanup) {
          mobileFocusTrapCleanup();
          mobileFocusTrapCleanup = null;
        }
        mobileFocusTrapCleanup = setupMobileFocusTrap();
      }, 100);
    }
  }

  function closeMobileSearch() {
    if (mobileSearchPopup) {
      // Clean up event listeners before closing
      if (mobileFocusTrapCleanup) {
        mobileFocusTrapCleanup();
        mobileFocusTrapCleanup = null;
      }
      mobileSearchPopup.classList.remove("active");
      if (mobileSearchInput) {
        mobileSearchInput.value = "";
      }
      if (mobileSearchResults) {
        mobileSearchResults.innerHTML = "";
        mobileSearchResults.style.display = "none";
      }
    }
  }

  if (closeMobileSearchBtn) {
    closeMobileSearchBtn.addEventListener("click", closeMobileSearch);
  }

  // Mobile search input
  if (mobileSearchInput && mobileSearchResults) {
    function handleMobileSearchInput() {
      clearTimeout(mobileSearchTimeout);
      const searchTerm = mobileSearchInput.value.trim();
      if (searchTerm.length < 2) {
        mobileSearchResults.innerHTML = "";
        mobileSearchResults.style.display = "none";
        return;
      }

      mobileSearchTimeout = setTimeout(async () => {
        // Verify the input still matches before proceeding
        if (mobileSearchInput.value.trim() !== searchTerm) return;

        // Show loading state
        mobileSearchResults.innerHTML =
          '<div class="search-result-item">Loading...</div>';
        mobileSearchResults.style.display = "block";

        try {
          const results = await window.searchNamespace.engine.search(
            searchTerm,
            8,
          );
          // Verify again after async operation
          if (mobileSearchInput.value.trim() !== searchTerm) return;

          if (results.length > 0) {
            mobileSearchResults.innerHTML = results
              .map((result) => {
                const { doc, matchingAnchors } = result;
                const queryTerms =
                  window.searchNamespace.engine.tokenize(searchTerm);
                const highlightedTitle =
                  window.searchNamespace.engine.highlightTerms(
                    doc.title,
                    queryTerms,
                  );
                const resolvedPath = window.searchNamespace.engine.resolvePath(
                  doc.path,
                );

                // Build page result
                let html = `
                  <div class="search-result-item search-result-page">
                    <a href="${resolvedPath}">${highlightedTitle}</a>
                  </div>
                `;

                // Add anchor results if any
                if (matchingAnchors && matchingAnchors.length > 0) {
                  matchingAnchors.forEach((anchor) => {
                    // Skip anchors that duplicate the page title
                    const normalizedAnchor =
                      window.searchNamespace.engine.normalizeForComparison(
                        anchor.text,
                      );
                    const normalizedTitle =
                      window.searchNamespace.engine.normalizeForComparison(
                        doc.title,
                      );
                    if (normalizedAnchor === normalizedTitle) {
                      return;
                    }

                    const highlightedAnchor =
                      window.searchNamespace.engine.highlightTerms(
                        anchor.text,
                        queryTerms,
                      );
                    const sectionPreview =
                      window.searchNamespace.engine.generateSectionPreview(
                        doc,
                        anchor,
                        searchTerm,
                        100,
                      );
                    const anchorPath = `${resolvedPath}#${anchor.id}`;
                    html += `
                      <div class="search-result-item search-result-anchor">
                        <a href="${anchorPath}">
                          <div class="search-result-anchor-text">${highlightedAnchor}</div>
                          <div class="search-result-preview">${sectionPreview}</div>
                        </a>
                      </div>
                    `;
                  });
                }

                return html;
              })
              .join("");
            mobileSearchResults.style.display = "block";
            // Clean up previous listeners before setting up new ones
            if (mobileFocusTrapCleanup) {
              mobileFocusTrapCleanup();
              mobileFocusTrapCleanup = null;
            }
            mobileFocusTrapCleanup = setupMobileFocusTrap();
          } else {
            mobileSearchResults.innerHTML =
              '<div class="search-result-item">No results found</div>';
            mobileSearchResults.style.display = "block";
          }
        } catch (error) {
          console.error("Mobile search error:", error);
          // Verify once more
          if (mobileSearchInput.value.trim() !== searchTerm) return;
          mobileSearchResults.innerHTML =
            '<div class="search-result-item search-error" role="alert">Search unavailable. <a href="#" onclick="event.preventDefault(); window.searchNamespace.engine.loadData();">Retry</a></div>';
          mobileSearchResults.style.display = "block";
        }
      }, 300);
    }

    mobileSearchInput.addEventListener("input", handleMobileSearchInput);
  }

  // Handle window resize to update mobile behavior
  window.addEventListener("resize", function () {
    // Close mobile search if window is resized to desktop size
    if (
      !isMobile() &&
      mobileSearchPopup &&
      mobileSearchPopup.classList.contains("active")
    ) {
      closeMobileSearch();
    }
  });
});

async function performSearch(query, keyboardNav = null) {
  query = query.trim();
  const resultsContainer = document.getElementById("search-page-results");

  if (query.length < 2) {
    resultsContainer.innerHTML =
      "<p>Please enter at least 2 characters to search</p>";
    if (keyboardNav) keyboardNav.clear();
    return;
  }

  // Cancel any pending search
  if (searchPageController) {
    searchPageController.abort();
  }
  searchPageController = new AbortController();

  // Show loading state
  resultsContainer.innerHTML = "<p>Searching...</p>";
  if (keyboardNav) keyboardNav.clear();

  try {
    const results = await window.searchNamespace.engine.search(query, 50, {
      signal: searchPageController.signal,
    });

    // Check if aborted before rendering
    if (searchPageController.signal.aborted) {
      return;
    }

    // Display results
    if (results.length > 0) {
      let html = '<ul class="search-results-list">';
      const queryTerms = window.searchNamespace.engine.tokenize(query);

      for (const result of results) {
        const { doc, matchingAnchors } = result;
        const highlightedTitle = window.searchNamespace.engine.highlightTerms(
          doc.title,
          queryTerms,
        );
        const preview = window.searchNamespace.engine.generatePreview(
          doc.content,
          query,
        );
        const resolvedPath = window.searchNamespace.engine.resolvePath(
          doc.path,
        );

        // Page result
        html += `<li class="search-result-item search-result-page">
          <a href="${resolvedPath}">
            <div class="search-result-title">${highlightedTitle}</div>
            <div class="search-result-preview">${preview}</div>
          </a>
        </li>`;

        // Anchor results
        if (matchingAnchors && matchingAnchors.length > 0) {
          matchingAnchors.forEach((anchor) => {
            // Skip anchors that have the same text as the page title to avoid duplication
            const normalizedAnchor =
              window.searchNamespace.engine.normalizeForComparison(anchor.text);
            const normalizedTitle =
              window.searchNamespace.engine.normalizeForComparison(doc.title);
            if (normalizedAnchor === normalizedTitle) {
              return;
            }

            const highlightedAnchor =
              window.searchNamespace.engine.highlightTerms(
                anchor.text,
                queryTerms,
              );
            const sectionPreview =
              window.searchNamespace.engine.generateSectionPreview(
                doc,
                anchor,
                query,
              );
            const anchorPath = `${resolvedPath}#${anchor.id}`;
            html += `<li class="search-result-item search-result-anchor">
              <a href="${anchorPath}">
                <div class="search-result-anchor-text">${highlightedAnchor}</div>
                <div class="search-result-preview">${sectionPreview}</div>
              </a>
            </li>`;
          });
        }
      }
      html += "</ul>";
      resultsContainer.innerHTML = html;
      if (keyboardNav) keyboardNav.updateItems();
    } else {
      resultsContainer.innerHTML = "<p>No results found</p>";
      if (keyboardNav) keyboardNav.clear();
    }

    // Update URL with query
    const url = new URL(window.location.href);
    url.searchParams.set("q", query);
    window.history.replaceState({}, "", url.toString());
  } catch (error) {
    if (error.name === "AbortError") {
      return;
    }
    console.error("Search error:", error);
    resultsContainer.innerHTML = `
      <div class="search-error" role="alert">
        <p>Search is temporarily unavailable. Please try again.</p>
        <button type="button" onclick="window.searchNamespace.engine.loadData().then(() => { this.closest('.search-error').innerHTML = '<p>Search reloaded. Please try your search again.</p>'; })">
          Retry
        </button>
      </div>
    `;
    if (keyboardNav) keyboardNav.clear();
  }
}
