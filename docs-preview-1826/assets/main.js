// Polyfill for requestIdleCallback for Safari and unsupported browsers
if (typeof window.requestIdleCallback === "undefined") {
  window.requestIdleCallback = function (cb) {
    const start = Date.now();
    const idlePeriod = 50;
    return setTimeout(function () {
      cb({
        didTimeout: false,
        timeRemaining: function () {
          return Math.max(0, idlePeriod - (Date.now() - start));
        },
      });
    }, 1);
  };
  window.cancelIdleCallback = function (id) {
    clearTimeout(id);
  };
}

let pageController;

function beginPageLifecycle() {
  pageController?.abort();
  pageController = new AbortController();
  return pageController.signal;
}

function schedulePageTask(signal, callback, delay) {
  const timeout = setTimeout(callback, delay);
  signal.addEventListener("abort", () => clearTimeout(timeout), { once: true });
}

// Create mobile elements if they don't exist
function createMobileElements() {
  const mobileToggle = document.createElement("button");
  mobileToggle.className = "mobile-sidebar-toggle";
  mobileToggle.type = "button";
  mobileToggle.setAttribute("aria-label", "Open contents");
  mobileToggle.setAttribute("aria-controls", "mobile-sidebar");
  mobileToggle.setAttribute("aria-expanded", "false");
  mobileToggle.innerHTML = `
    <svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="3" y1="12" x2="21" y2="12"></line>
      <line x1="3" y1="6" x2="21" y2="6"></line>
      <line x1="3" y1="18" x2="21" y2="18"></line>
    </svg>
  `;

  const header = document.querySelector("header");
  if (header) {
    header.insertBefore(mobileToggle, header.firstChild);
  }

  const mobileBackdrop = document.createElement("div");
  mobileBackdrop.className = "mobile-sidebar-backdrop";
  mobileBackdrop.hidden = true;

  const mobileContainer = document.createElement("div");
  mobileContainer.id = "mobile-sidebar";
  mobileContainer.className = "mobile-sidebar-container";
  mobileContainer.setAttribute("role", "dialog");
  mobileContainer.setAttribute("aria-modal", "true");
  mobileContainer.setAttribute("aria-labelledby", "mobile-sidebar-title");
  mobileContainer.setAttribute("aria-hidden", "true");
  mobileContainer.inert = true;
  mobileContainer.innerHTML = `
    <div class="mobile-sidebar-header">
      <h2 id="mobile-sidebar-title">Menu</h2>
      <button type="button" class="mobile-sidebar-close" aria-label="Close contents">&times;</button>
    </div>
    <nav class="mobile-sidebar-site-nav" aria-label="Site navigation"></nav>
    <div class="mobile-sidebar-content">
      <!-- Sidebar content will be cloned here -->
    </div>
  `;

  // Create mobile search popup
  const mobileSearchPopup = document.createElement("div");
  mobileSearchPopup.id = "mobile-search-popup";
  mobileSearchPopup.className = "mobile-search-popup";
  mobileSearchPopup.setAttribute("role", "dialog");
  mobileSearchPopup.setAttribute("aria-modal", "true");
  mobileSearchPopup.setAttribute("aria-label", "Search");
  mobileSearchPopup.innerHTML = `
    <div class="mobile-search-container" role="document">
      <div class="mobile-search-header">
        <input type="search" id="mobile-search-input" placeholder="Search..." aria-label="Search" autocomplete="off" />
        <button type="button" id="close-mobile-search" class="close-mobile-search" aria-label="Close search">&times;</button>
      </div>
      <div id="mobile-search-results" class="mobile-search-results" role="region" aria-live="polite" aria-label="Search results"></div>
    </div>
  `;

  // Insert at end of body so it is not affected by .container flex or stacking context
  document.body.appendChild(mobileBackdrop);
  document.body.appendChild(mobileContainer);
  document.body.appendChild(mobileSearchPopup);
}

// Highlight search terms on target pages
function highlightTextInContent(container, terms, signal) {
  if (!container || !terms || terms.length === 0) return;

  // Create a case-insensitive regex pattern
  const pattern = terms
    .map((term) => term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
    .join("|");
  const regex = new RegExp(`(${pattern})`, "gi");

  // Elements to skip highlighting
  const skipTags = new Set(["SCRIPT", "STYLE", "CODE", "PRE", "MARK"]);

  function highlightNode(node) {
    if (node.nodeType === Node.TEXT_NODE) {
      const text = node.textContent;
      // Use match instead of test to avoid regex state issues
      if (text.match(regex)) {
        const span = document.createElement("span");
        // Create a fresh regex for replace to avoid state issues
        const replaceRegex = new RegExp(`(${pattern})`, "gi");
        span.innerHTML = text.replace(
          replaceRegex,
          '<mark class="search-highlight">$1</mark>',
        );
        node.replaceWith(...Array.from(span.childNodes));
      }
    } else if (
      node.nodeType === Node.ELEMENT_NODE &&
      !skipTags.has(node.tagName)
    ) {
      Array.from(node.childNodes).forEach(highlightNode);
    }
  }

  highlightNode(container);

  // Scroll to first highlight after a brief delay
  schedulePageTask(
    signal,
    () => {
      const firstHighlight = container.querySelector(".search-highlight");
      if (firstHighlight) {
        firstHighlight.scrollIntoView({ behavior: "smooth", block: "center" });
        firstHighlight.classList.add("search-highlight-active");
      }
    },
    100,
  );
}

// Initialize scroll spy
function initScrollSpy(signal) {
  const pageToc = document.querySelector(".page-toc");
  if (!pageToc) return;

  const tocLinks = pageToc.querySelectorAll(".page-toc-list a");
  const content = document.querySelector(".content");
  if (!tocLinks.length || !content) return;

  const headings = Array.from(
    content.querySelectorAll("h1[id], h2[id], h3[id]"),
  );

  if (!headings.length) return;

  // Build ordered (heading, tocLink) pairs. Using a queue per ID handles
  // duplicate heading text correctly: the first TOC link for a given href
  // is paired with the first heading carrying that ID in document order, the
  // second TOC link with the second heading, etc.
  const headingQueues = new Map();
  headings.forEach((h) => {
    if (!headingQueues.has(h.id)) headingQueues.set(h.id, []);
    headingQueues.get(h.id).push(h);
  });

  const pairs = [];
  tocLinks.forEach((link) => {
    const href = link.getAttribute("href");
    if (!href || !href.startsWith("#")) return;
    const id = href.slice(1);
    const queue = headingQueues.get(id);
    if (queue?.length) {
      pairs.push({ heading: queue.shift(), link });
    }
  });

  // Ensure pairs are sorted by document position in case the TOC order ever
  // diverges from heading order.
  pairs.sort(
    (a, b) => headings.indexOf(a.heading) - headings.indexOf(b.heading),
  );

  let activeLink = null;

  // Update active link based on scroll position
  function updateActiveLink() {
    const threshold = 120; // threshold from the top of the viewport

    let currentPair = null;

    // Find the last heading that is at or above the threshold
    for (const pair of pairs) {
      const rect = pair.heading.getBoundingClientRect();
      if (rect.top <= threshold) {
        currentPair = pair;
      }
    }

    // If no heading is above threshold, use first heading if it's in view
    if (!currentPair && pairs.length > 0) {
      const firstRect = pairs[0].heading.getBoundingClientRect();
      if (firstRect.top < window.innerHeight) {
        currentPair = pairs[0];
      }
    }

    const newLink = currentPair?.link ?? null;

    if (newLink !== activeLink) {
      if (activeLink) {
        activeLink.classList.remove("active");
      }
      if (newLink) {
        newLink.classList.add("active");
      }
      activeLink = newLink;
    }
  }

  // Scroll event handler
  let frame = 0;
  function onScroll() {
    if (!frame) {
      frame = requestAnimationFrame(() => {
        updateActiveLink();
        frame = 0;
      });
    }
  }

  window.addEventListener("scroll", onScroll, { passive: true, signal });

  // Also update on hash change (direct link navigation)
  window.addEventListener(
    "hashchange",
    () => {
      requestAnimationFrame(updateActiveLink);
    },
    { signal },
  );

  // Set initial active state after a small delay to ensure
  // browser has completed any hash-based scrolling
  const timeout = setTimeout(updateActiveLink, 100);
  signal.addEventListener(
    "abort",
    () => {
      clearTimeout(timeout);
      cancelAnimationFrame(frame);
    },
    { once: true },
  );
}

function initMobileNavigation() {
  const mobileSidebarContainer = document.querySelector(
    ".mobile-sidebar-container",
  );
  const mobileSidebarToggle = document.querySelector(".mobile-sidebar-toggle");
  const mobileSidebarBackdrop = document.querySelector(
    ".mobile-sidebar-backdrop",
  );
  const mobileSidebarClose = document.querySelector(".mobile-sidebar-close");

  if (!mobileSidebarToggle || !mobileSidebarContainer || !mobileSidebarBackdrop)
    return;

  const openMobileSidebar = () => {
    refreshMobileNavigation();
    mobileSidebarContainer.inert = false;
    mobileSidebarContainer.classList.add("active");
    mobileSidebarBackdrop.hidden = false;
    mobileSidebarBackdrop.classList.add("active");
    mobileSidebarToggle.setAttribute("aria-expanded", "true");
    mobileSidebarContainer.setAttribute("aria-hidden", "false");
    document.body.classList.add("mobile-sidebar-open");
    mobileSidebarClose?.focus();
  };

  const closeMobileSidebar = (restoreFocus = true) => {
    mobileSidebarContainer.classList.remove("active");
    mobileSidebarBackdrop.classList.remove("active");
    mobileSidebarToggle.setAttribute("aria-expanded", "false");
    mobileSidebarContainer.setAttribute("aria-hidden", "true");
    mobileSidebarContainer.inert = true;
    document.body.classList.remove("mobile-sidebar-open");
    if (restoreFocus) {
      mobileSidebarToggle.focus();
    }
    setTimeout(() => {
      if (!mobileSidebarBackdrop.classList.contains("active")) {
        mobileSidebarBackdrop.hidden = true;
      }
    }, 200);
  };

  mobileSidebarToggle.addEventListener("click", (e) => {
    e.stopPropagation();
    if (mobileSidebarContainer.classList.contains("active")) {
      closeMobileSidebar();
    } else {
      openMobileSidebar();
    }
  });

  mobileSidebarBackdrop.addEventListener("click", () => closeMobileSidebar());
  mobileSidebarClose?.addEventListener("click", () => closeMobileSidebar());
  mobileSidebarContainer.addEventListener("click", (event) => {
    if (event.target instanceof Element && event.target.closest("a")) {
      closeMobileSidebar(false);
    }
  });
  window.addEventListener("resize", () => {
    if (window.innerWidth > 800) {
      closeMobileSidebar(false);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (!mobileSidebarContainer.classList.contains("active")) return;

    if (event.key === "Escape") {
      event.preventDefault();
      closeMobileSidebar();
      return;
    }

    if (event.key !== "Tab") return;

    const focusable = Array.from(
      mobileSidebarContainer.querySelectorAll(
        'a[href], button:not([disabled]), summary, input:not([disabled]), [tabindex]:not([tabindex="-1"])',
      ),
    ).filter((element) => element.getClientRects().length > 0);
    if (focusable.length === 0) return;

    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  });
}

function isEditableTarget(target) {
  return (
    target instanceof HTMLElement &&
    (target.isContentEditable ||
      ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName))
  );
}

function setupGlobalShortcuts() {
  document.addEventListener("keydown", (event) => {
    if (
      event.key !== "/" ||
      event.ctrlKey ||
      event.metaKey ||
      event.altKey ||
      isEditableTarget(event.target)
    ) {
      return;
    }

    const input =
      document.getElementById("options-filter") ??
      document.getElementById("search-page-input") ??
      document.getElementById("search-input");
    if (!input) return;

    event.preventDefault();
    input.focus();
  });
}

function setupNavbarKeyboardNavigation() {
  document.querySelectorAll(".header-nav").forEach((nav) => {
    nav.addEventListener("keydown", (event) => {
      if (!(event.target instanceof HTMLAnchorElement)) return;
      if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) {
        return;
      }

      const links = Array.from(nav.querySelectorAll("a[href]"));
      const currentIndex = links.indexOf(event.target);
      if (currentIndex < 0 || links.length === 0) return;

      event.preventDefault();
      let nextIndex = currentIndex;
      if (event.key === "ArrowLeft") {
        nextIndex = (currentIndex - 1 + links.length) % links.length;
      } else if (event.key === "ArrowRight") {
        nextIndex = (currentIndex + 1) % links.length;
      } else if (event.key === "Home") {
        nextIndex = 0;
      } else if (event.key === "End") {
        nextIndex = links.length - 1;
      }
      links[nextIndex].focus();
    });
  });
}

function setupOptionKeyboardNavigation(signal) {
  const input = document.getElementById("options-filter");
  const container = document.querySelector(
    ".options-index-list, .options-container",
  );
  if (!input || !container) return;

  const optionLinks = () =>
    Array.from(
      container.querySelectorAll(".option .option-anchor, .option-page-row"),
    );
  const focusOption = (link) => {
    link.focus({ preventScroll: true });
    link
      .closest(".option, .option-page-row")
      ?.scrollIntoView({ block: "nearest", inline: "nearest" });
  };

  input.addEventListener(
    "keydown",
    (event) => {
      if (event.key !== "ArrowDown") return;
      const first = optionLinks()[0];
      if (!first) return;
      event.preventDefault();
      focusOption(first);
    },
    { signal },
  );

  container.addEventListener(
    "keydown",
    (event) => {
      if (!(event.target instanceof HTMLAnchorElement)) return;
      if (
        !["ArrowUp", "ArrowDown", "Home", "End", "Escape"].includes(event.key)
      ) {
        return;
      }

      event.preventDefault();
      if (event.key === "Escape") {
        input.focus();
        return;
      }

      const links = optionLinks();
      const currentIndex = links.indexOf(event.target);
      if (currentIndex < 0 || links.length === 0) return;

      let nextIndex = currentIndex;
      if (event.key === "ArrowUp") {
        nextIndex = Math.max(0, currentIndex - 1);
      } else if (event.key === "ArrowDown") {
        nextIndex = Math.min(links.length - 1, currentIndex + 1);
      } else if (event.key === "Home") {
        nextIndex = 0;
      } else if (event.key === "End") {
        nextIndex = links.length - 1;
      }

      focusOption(links[nextIndex]);
    },
    { signal },
  );
}

let optionScrollRequest = 0;

function scrollToOption(element) {
  const request = ++optionScrollRequest;
  const container = element?.closest(".options-container");
  container?.classList.add("options-revealed");

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      if (request !== optionScrollRequest || !element?.isConnected) return;
      element.scrollIntoView({
        behavior: "instant",
        block: "start",
      });
      requestAnimationFrame(() => {
        if (request === optionScrollRequest) {
          container?.classList.remove("options-revealed");
        }
      });
    });
  });
}

function setupOptionTocNavigation() {
  document.addEventListener("click", (event) => {
    if (!(event.target instanceof Element)) return;
    const link = event.target.closest('a[href^="#"]');
    if (
      !link ||
      !link.closest('.options-page [data-section="toc"] .toc-list')
    ) {
      return;
    }

    const target = document.getElementById(
      decodeURIComponent(link.hash.slice(1)),
    );
    if (!target) return;

    event.preventDefault();
    history.pushState(null, "", link.hash);
    scrollToOption(target);
  });
}

function setupOptionChunkLoading(signal) {
  const manifestElement = document.getElementById("options-chunk-manifest");
  const loader = document.querySelector(".options-chunk-loader");
  if (!manifestElement || !loader) return null;

  const status = loader.querySelector(".options-chunk-status");
  const chunks = Array.from(loader.querySelectorAll("[data-options-chunk]"));
  let manifest;
  try {
    manifest = JSON.parse(manifestElement.textContent);
  } catch {
    if (status)
      status.textContent = "The remaining options could not be loaded.";
    return null;
  }

  const requests = new Map();
  const loadedChunks = new Set();
  let nextChunk = 0;

  const updateStatus = () => {
    const loaded = loadedChunks.size;
    if (!status) return;
    if (loaded === chunks.length) {
      status.remove();
    } else {
      status.textContent = `Loaded ${loaded + 1} of ${chunks.length + 1} option chunks.`;
    }
  };

  const loadChunk = (index) => {
    if (!Number.isInteger(index) || !chunks[index]) return Promise.resolve();
    if (requests.has(index)) return requests.get(index);

    const chunk = chunks[index];
    const request = fetch(chunk.dataset.src, { signal })
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.text();
      })
      .then((html) => {
        chunk.innerHTML = html;
        chunk.removeAttribute("data-src");
        loadedChunks.add(index);
        updateStatus();
      })
      .catch((error) => {
        if (error.name === "AbortError") return;
        chunk.classList.add("options-chunk-error");
        chunk.textContent = "This option chunk could not be loaded.";
        if (status) status.textContent = "Some options could not be loaded.";
        throw error;
      });
    requests.set(index, request);
    return request;
  };

  const loadAll = () => Promise.all(chunks.map((_, index) => loadChunk(index)));
  const loadThrough = (index) =>
    Promise.all(chunks.slice(0, index + 1).map((_, i) => loadChunk(i)));

  const revealHashTarget = async () => {
    const id = decodeURIComponent(window.location.hash.slice(1));
    const chunkIndex = manifest.option_chunks?.[id];
    try {
      if (Number.isInteger(chunkIndex)) await loadThrough(chunkIndex);
    } catch {
      return;
    }
    if (signal.aborted) return;
    const target = document.getElementById(id);
    if (!target?.classList.contains("option")) return;
    target.classList.add("highlight");
    scrollToOption(target);
  };

  const loadNext = () => {
    while (requests.has(nextChunk)) nextChunk += 1;
    if (nextChunk >= chunks.length) return Promise.resolve();
    const index = nextChunk;
    nextChunk += 1;
    return loadChunk(index);
  };

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
          void loadNext().catch(() => {});
        }
      },
      { rootMargin: "1000px" },
    );
    observer.observe(status ?? loader);
    signal.addEventListener("abort", () => observer.disconnect(), {
      once: true,
    });
  } else {
    window.requestIdleCallback(() => void loadAll().catch(() => {}));
  }

  window.addEventListener("hashchange", () => void revealHashTarget(), {
    signal,
  });
  const hashReady = window.location.hash
    ? revealHashTarget()
    : Promise.resolve();

  return { hashReady, loadAll };
}

function getFilterMatches(searchTerm, originalOrder, data) {
  if (searchTerm === "") {
    return originalOrder.map((element, index) => ({ element, index }));
  }

  const terms = searchTerm.split(/\s+/).filter(Boolean);
  const firstTerm = terms[0] || "";

  return data
    .filter((item) => terms.every((term) => item.searchText.includes(term)))
    .sort((a, b) => {
      const aRank = a.name.includes(firstTerm) ? 0 : 1;
      const bRank = b.name.includes(firstTerm) ? 0 : 1;
      if (aRank !== bRank) return aRank - bRank;
      const aPos = a.name.includes(firstTerm)
        ? a.name.indexOf(firstTerm)
        : a.searchText.indexOf(firstTerm);
      const bPos = b.name.includes(firstTerm)
        ? b.name.indexOf(firstTerm)
        : b.searchText.indexOf(firstTerm);
      return aPos - bPos || a.index - b.index;
    });
}

function reconcileFilteredItems({
  container,
  hiddenContainer,
  matches,
  data,
  reduceMotion,
  animateChanges,
  isCurrentRun,
}) {
  const visibleElements = new Set(matches.map((item) => item.element));
  const leaving = [];

  for (const item of data) {
    if (visibleElements.has(item.element)) continue;
    if (
      !animateChanges ||
      reduceMotion.matches ||
      !container.contains(item.element)
    ) {
      hiddenContainer.content.appendChild(item.element);
    } else {
      item.element.classList.add("filter-leaving");
      leaving.push(item.element);
    }
  }

  const updateVisibleItems = () => {
    if (!isCurrentRun()) return;
    for (const element of leaving) {
      element.classList.remove("filter-leaving");
      if (!visibleElements.has(element)) {
        hiddenContainer.content.appendChild(element);
      }
    }

    const entering = [];
    let reference = container.firstChild;
    for (const item of matches) {
      const wasHidden = !container.contains(item.element);
      if (wasHidden && animateChanges && !reduceMotion.matches) {
        item.element.classList.add("filter-entering");
        entering.push(item.element);
      }

      if (item.element === reference) {
        reference = reference.nextSibling;
      } else {
        container.insertBefore(item.element, reference);
      }
    }

    if (entering.length > 0) {
      requestAnimationFrame(() => {
        for (const element of entering) {
          element.classList.remove("filter-entering");
        }
      });
    }
  };

  if (leaving.length > 0 && animateChanges) {
    setTimeout(updateVisibleItems, 160);
  } else {
    updateVisibleItems();
  }
}

function setupListFilter(
  { inputId, containerSelector, itemSelector, nameSelector, noun, prepare },
  signal,
) {
  const input = document.getElementById(inputId);
  const container = document.querySelector(containerSelector);
  if (!input || !container) return;

  const hiddenContainer = document.createElement("template");
  document.body.appendChild(hiddenContainer);

  const filterResults = document.createElement("div");
  filterResults.className = "filter-results";
  input.parentNode.insertBefore(filterResults, input.nextSibling);

  const isMobile =
    window.innerWidth < 768 || /Mobi|Android/i.test(navigator.userAgent);
  let filterData = prepare ? null : collectFilterData();

  let lastTerm = "";
  let timeout = null;
  let filterRun = 0;
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  function collectFilterData() {
    const items = Array.from(container.querySelectorAll(itemSelector));
    return {
      totalCount: items.length,
      animateChanges: items.length <= 100,
      originalOrder: items,
      data: items.map((element, index) => {
        const name = element.querySelector(nameSelector)?.textContent ?? "";
        return {
          element,
          index,
          name: name.toLowerCase(),
          searchText:
            `${element.id || ""} ${element.textContent || ""}`.toLowerCase(),
        };
      }),
    };
  }

  const applyFilter = async () => {
    if (!filterData && prepare) {
      try {
        await prepare();
      } catch {
        return;
      }
      if (signal.aborted) return;
      filterData = collectFilterData();
    }
    if (!filterData) return;

    const { totalCount, animateChanges, originalOrder, data } = filterData;
    const searchTerm = input.value.toLowerCase().trim();
    if (lastTerm === searchTerm) return;
    lastTerm = searchTerm;
    filterRun += 1;
    const currentRun = filterRun;
    for (const item of data) {
      item.element.classList.remove("filter-entering", "filter-leaving");
    }

    const matches = getFilterMatches(searchTerm, originalOrder, data);
    reconcileFilteredItems({
      container,
      hiddenContainer,
      matches,
      data,
      reduceMotion,
      animateChanges,
      isCurrentRun: () => currentRun === filterRun,
    });

    if (searchTerm !== "" && matches.length < totalCount) {
      filterResults.textContent = `Showing ${matches.length} of ${totalCount} ${noun}`;
      filterResults.style.display = "block";
    } else {
      filterResults.style.display = "none";
    }
  };

  const debounce = () => {
    clearTimeout(timeout);
    timeout = setTimeout(() => void applyFilter(), isMobile ? 200 : 100);
  };

  input.addEventListener("input", debounce, { signal });
  input.addEventListener(
    "keydown",
    (e) => {
      if (e.key === "Escape") {
        input.value = "";
        void applyFilter();
      }
    },
    { signal },
  );
  document.addEventListener(
    "visibilitychange",
    () => {
      if (!document.hidden && input.value) void applyFilter();
    },
    { signal },
  );
  signal.addEventListener(
    "abort",
    () => {
      clearTimeout(timeout);
      hiddenContainer.remove();
    },
    { once: true },
  );

  if (input.value) void applyFilter();
}

// Mark the current top-nav item active by matching the URL, so it works for
// every entry (Options, Search, ...) rather than relying on server-side flags.
function markActiveNav() {
  const normalize = (p) => p.replace(/index\.html$/, "").replace(/\/$/, "");
  const here = normalize(window.location.pathname);
  document
    .querySelectorAll(".header-nav li.active")
    .forEach((item) => item.classList.remove("active"));
  document.querySelectorAll(".header-nav a[href]").forEach((link) => {
    const linkPath = normalize(
      new URL(link.getAttribute("href"), window.location.href).pathname,
    );
    if (linkPath && linkPath === here) {
      link.closest("li")?.classList.add("active");
    }
  });
}

function clientPageName(url) {
  const name = new URL(url, window.location.href).pathname.split("/").pop();
  return name === "" ? "index.html" : name;
}

function isOptionsPageUrl(url) {
  const target = new URL(url, window.location.href);
  return (
    target.origin === window.location.origin &&
    clientPageName(target) === "options.html"
  );
}

function isPlainNavigationClick(event) {
  return (
    !event.defaultPrevented &&
    event.button === 0 &&
    !event.ctrlKey &&
    !event.metaKey &&
    !event.shiftKey &&
    !event.altKey &&
    event.target instanceof Element
  );
}

async function loadClientPage(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const markup = await response.text();
  return new DOMParser().parseFromString(markup, "text/html");
}

function replaceClientPage(next, url, push, scrollX, scrollY) {
  const currentSidebar = document.querySelector(".sidebar");
  const currentContent = document.querySelector(".content");
  const nextSidebar = next.querySelector(".sidebar");
  const nextContent = next.querySelector(".content");
  if (
    [currentSidebar, currentContent, nextSidebar, nextContent].some(
      (item) => !item,
    )
  ) {
    throw new Error("page is missing its sidebar or content");
  }

  if (push) {
    history.replaceState(
      Object.assign({}, history.state, {
        ndgClientPage: true,
        scrollX: window.scrollX,
        scrollY: window.scrollY,
      }),
      "",
      window.location.href,
    );
    history.pushState({ ndgClientPage: true, scrollX: 0, scrollY: 0 }, "", url);
  }

  const collapsed =
    document.documentElement.classList.contains("sidebar-collapsed");
  document.title = next.title;
  document.body.className = next.body.className;
  if (collapsed) document.body.classList.add("sidebar-collapsed");

  currentSidebar.replaceWith(nextSidebar);
  currentContent.replaceWith(nextContent);
  document.querySelector(".page-toc")?.remove();
  const nextPageToc = next.querySelector(".page-toc");
  if (nextPageToc) {
    document.querySelector(".container > footer")?.before(nextPageToc);
  }

  initializePage();
  refreshMobileNavigation();
  requestAnimationFrame(() => window.scrollTo(scrollX, scrollY));
}

function transitionClientPage(update) {
  if (!document.startViewTransition) {
    update();
    return Promise.resolve();
  }
  return document.startViewTransition(update).updateCallbackDone;
}

function setupClientNavigation() {
  history.scrollRestoration = "manual";
  history.replaceState(
    Object.assign({}, history.state, {
      ndgClientPage: true,
      scrollX: window.scrollX,
      scrollY: window.scrollY,
    }),
    "",
    window.location.href,
  );

  let navigating = false;
  const navigate = async (url, push, scrollX, scrollY) => {
    if (navigating) return;
    navigating = true;
    try {
      const next = await loadClientPage(url);
      await transitionClientPage(() =>
        replaceClientPage(next, url, push, scrollX, scrollY),
      );
    } catch {
      window.location.assign(url);
    } finally {
      navigating = false;
    }
  };

  document.addEventListener("click", (event) => {
    if (!isPlainNavigationClick(event)) return;
    const link = event.target.closest("a[href]");
    if (!link || link.target || link.hasAttribute("download")) return;

    const url = new URL(link.href, window.location.href);
    if (
      !isOptionsPageUrl(url) ||
      clientPageName(window.location.href) === "options.html"
    ) {
      return;
    }

    event.preventDefault();
    navigate(url.href, true, 0, 0);
  });

  window.addEventListener("popstate", (event) => {
    if (!event.state?.ndgClientPage) {
      window.location.assign(window.location.href);
      return;
    }
    if (!isOptionsPageUrl(window.location.href)) {
      history.scrollRestoration = "auto";
      window.location.reload();
      return;
    }
    const scrollX = Number.isFinite(event.state.scrollX)
      ? event.state.scrollX
      : 0;
    const scrollY = Number.isFinite(event.state.scrollY)
      ? event.state.scrollY
      : 0;
    navigate(window.location.href, false, scrollX, scrollY);
  });
}

function refreshMobileNavigation() {
  const mobileContainer = document.querySelector(".mobile-sidebar-container");
  if (!mobileContainer) return;

  const sidebar = document.querySelector(".sidebar");
  const mobileContent = document.querySelector(".mobile-sidebar-content");
  if (sidebar && mobileContent) {
    mobileContent.innerHTML = sidebar.innerHTML;
  }

  const headerNav = document.querySelector(".header-nav ul");
  const mobileSiteNav = document.querySelector(".mobile-sidebar-site-nav");
  if (headerNav && mobileSiteNav) {
    mobileSiteNav.innerHTML = headerNav.outerHTML;
  }
}

function setupOptionsFilter(signal, optionChunks) {
  const optionsIndexList = document.querySelector(".options-index-list");
  let config = {
    inputId: "options-filter",
    containerSelector: ".options-container",
    itemSelector: ".option",
    nameSelector: ".option-name",
    noun: "options",
    prepare: optionChunks?.loadAll,
  };
  if (optionsIndexList) {
    config = {
      inputId: "options-filter",
      containerSelector: ".options-index-list",
      itemSelector: ".option-page-row",
      nameSelector: ".option-page-title",
      noun: "option groups",
    };
  }
  setupListFilter(config, signal);
  setupOptionKeyboardNavigation(signal);
}

function setupOptionsPage(signal, content) {
  const optionChunks = setupOptionChunkLoading(signal);

  if (window.location.hash) {
    const targetElement = document.getElementById(
      decodeURIComponent(window.location.hash.slice(1)),
    );
    if (targetElement) {
      if (targetElement.classList.contains("option")) {
        schedulePageTask(signal, () => scrollToOption(targetElement), 100);
        targetElement.classList.add("highlight");
      } else {
        schedulePageTask(
          signal,
          () => {
            const offset =
              targetElement.getBoundingClientRect().top + window.scrollY - 80;
            window.scrollTo({ top: offset, behavior: "smooth" });
          },
          0,
        );
      }
    }
  }

  setupOptionsFilter(signal, optionChunks);

  const highlightQuery = new URLSearchParams(window.location.search).get(
    "highlight",
  );
  if (!highlightQuery || !content) return;

  const queryTerms = highlightQuery
    .toLowerCase()
    .trim()
    .split(/\s+/)
    .filter((term) => term.length >= 2);
  if (queryTerms.length === 0) return;

  const ready = optionChunks
    ? window.location.hash
      ? optionChunks.hashReady
      : optionChunks.loadAll()
    : Promise.resolve();
  void ready
    .then(() => {
      if (!signal.aborted) highlightTextInContent(content, queryTerms, signal);
    })
    .catch(() => {});
}

function initializePage() {
  const signal = beginPageLifecycle();

  // Highlight the active nav item before the mobile nav is cloned from it.
  markActiveNav();

  // Initialize scroll spy for page TOC
  initScrollSpy(signal);

  // Template container for collapsed sidebar content (prevents Ctrl+F from finding hidden content)
  const sidebarHiddenContainer = document.createElement("template");

  // Handle sidebar section toggles - move content to template when collapsed
  document
    .querySelectorAll(".sidebar-section > .sidebar-section-content")
    .forEach((content) => {
      const details = content.parentElement;
      const toggleContent = () => {
        if (details.hasAttribute("open")) {
          // Section opened - move content back to DOM
          if (sidebarHiddenContainer.content.contains(content)) {
            const summary = details.querySelector("summary");
            details.insertBefore(
              content,
              summary ? summary.nextSibling : details.firstChild,
            );
          }
        } else {
          // Section closed - move content to template (removes from DOM, Ctrl+F won't find it)
          if (content.parentElement === details) {
            sidebarHiddenContainer.content.appendChild(content);
          }
        }
      };

      // Use MutationObserver to detect open/close changes
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.attributeName === "open") {
            toggleContent();
          }
        });
      });

      observer.observe(details, { attributes: true });
      signal.addEventListener("abort", () => observer.disconnect(), {
        once: true,
      });

      // Initial state check
      if (!details.hasAttribute("open")) {
        sidebarHiddenContainer.content.appendChild(content);
      }
    });

  // Desktop Sidebar Toggle
  const sidebarToggle = document.querySelector(".sidebar-toggle");

  // On page load, sync the state from `documentElement` to `body`
  if (document.documentElement.classList.contains("sidebar-collapsed")) {
    document.body.classList.add("sidebar-collapsed");
  }

  if (sidebarToggle) {
    const syncSidebarToggle = () => {
      const isCollapsed =
        document.documentElement.classList.contains("sidebar-collapsed");
      sidebarToggle.setAttribute("aria-expanded", String(!isCollapsed));
      sidebarToggle.setAttribute(
        "aria-label",
        isCollapsed ? "Expand sidebar" : "Collapse sidebar",
      );
    };
    syncSidebarToggle();

    sidebarToggle.addEventListener(
      "click",
      function () {
        // Toggle on both elements for consistency
        document.documentElement.classList.toggle("sidebar-collapsed");
        document.body.classList.toggle("sidebar-collapsed");

        // Use documentElement to check state and save to localStorage
        const isCollapsed =
          document.documentElement.classList.contains("sidebar-collapsed");
        syncSidebarToggle();
        try {
          localStorage.setItem("sidebar-collapsed", isCollapsed);
        } catch {
          // localStorage unavailable
        }
      },
      { signal },
    );
  }

  // Make headings clickable for anchor links
  const content = document.querySelector(".content");
  if (content) {
    const headings = content.querySelectorAll(
      "h1:not(.option-name), h2:not(.option-name), h3:not(.option-name), h4:not(.option-name), h5:not(.option-name), h6:not(.option-name)",
    );

    headings.forEach(function (heading) {
      // Generate a valid, unique ID for each heading
      if (!heading.id) {
        let baseId = heading.textContent
          .toLowerCase()
          .replace(/[^a-z0-9\s-_]/g, "") // remove invalid chars
          .replace(/^[^a-z]+/, "") // remove leading non-letters
          .replace(/[\s-_]+/g, "-")
          .replace(/^-+|-+$/g, "") // trim leading/trailing dashes
          .trim();
        if (!baseId) {
          baseId = "section";
        }
        let id = baseId;
        let counter = 1;
        while (document.getElementById(id)) {
          id = `${baseId}-${counter++}`;
        }
        heading.id = id;
      }

      // Make the entire heading clickable
      heading.addEventListener(
        "click",
        function () {
          const id = this.id;
          history.pushState(null, null, "#" + id);

          // Scroll with offset
          const offset = this.getBoundingClientRect().top + window.scrollY - 80;
          window.scrollTo({
            top: offset,
            behavior: "smooth",
          });
        },
        { signal },
      );
    });
  }

  // Process footnotes
  if (content) {
    const footnoteContainer = document.querySelector(".footnotes-container");

    // Find all footnote references and create a footnotes section
    const footnoteRefs = content.querySelectorAll('a[href^="#fn"]');
    if (footnoteRefs.length > 0 && footnoteContainer) {
      const footnotesDiv = document.createElement("div");
      footnotesDiv.className = "footnotes";

      const footnotesHeading = document.createElement("h2");
      footnotesHeading.textContent = "Footnotes";
      footnotesDiv.appendChild(footnotesHeading);

      const footnotesList = document.createElement("ol");
      footnoteContainer.appendChild(footnotesDiv);
      footnotesDiv.appendChild(footnotesList);

      // Add footnotes
      document.querySelectorAll(".footnote").forEach((footnote) => {
        const id = footnote.id;
        const content = footnote.innerHTML;

        const li = document.createElement("li");
        li.id = id;
        li.innerHTML = content;

        // Add backlink
        const backlink = document.createElement("a");
        backlink.href = "#fnref:" + id.replace("fn:", "");
        backlink.className = "footnote-backlink";
        backlink.textContent = "↩";
        li.appendChild(backlink);

        footnotesList.appendChild(li);
      });
    }
  }

  // One delegated handler avoids attaching a listener to every option card.
  content?.addEventListener(
    "click",
    function (event) {
      if (!(event.target instanceof Element)) return;
      const copyLink = event.target.closest(".copy-link");
      if (!copyLink) return;

      event.preventDefault();
      event.stopPropagation();

      const option = copyLink.closest(".option");
      if (!option) return;

      const url = new URL(window.location.href);
      url.hash = option.id;

      navigator.clipboard
        .writeText(url.toString())
        .then(function () {
          const feedback = copyLink.nextElementSibling;
          if (!feedback) return;
          feedback.style.display = "inline";

          setTimeout(function () {
            feedback.style.display = "none";
          }, 2000);
        })
        .catch(function (err) {
          console.error("Could not copy link: ", err);
        });
    },
    { signal },
  );

  setupOptionsPage(signal, content);

  setupListFilter(
    {
      inputId: "lib-filter",
      containerSelector: ".lib-container",
      itemSelector: ".lib-entry",
      nameSelector: ".lib-entry-name",
      noun: "functions",
    },
    signal,
  );
}

function initializeGlobalBehavior() {
  if (!document.querySelector(".mobile-sidebar-toggle")) createMobileElements();
  initMobileNavigation();
  setupGlobalShortcuts();
  setupNavbarKeyboardNavigation();
  setupOptionTocNavigation();
  setupClientNavigation();
}

document.addEventListener("DOMContentLoaded", () => {
  initializeGlobalBehavior();
  initializePage();
});
