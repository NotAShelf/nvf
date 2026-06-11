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

// Create mobile elements if they don't exist
function createMobileElements() {
  // Create mobile sidebar FAB
  const mobileFab = document.createElement("button");
  mobileFab.className = "mobile-sidebar-fab";
  mobileFab.setAttribute("aria-label", "Toggle sidebar menu");
  mobileFab.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="3" y1="12" x2="21" y2="12"></line>
      <line x1="3" y1="6" x2="21" y2="6"></line>
      <line x1="3" y1="18" x2="21" y2="18"></line>
    </svg>
  `;

  // Only show FAB on mobile (max-width: 800px)
  function updateFabVisibility() {
    if (window.innerWidth > 800) {
      if (mobileFab.parentNode) mobileFab.parentNode.removeChild(mobileFab);
    } else {
      if (!document.body.contains(mobileFab)) {
        document.body.appendChild(mobileFab);
      }
      mobileFab.style.display = "flex";
    }
  }
  updateFabVisibility();
  window.addEventListener("resize", updateFabVisibility);

  // Create mobile sidebar container
  const mobileContainer = document.createElement("div");
  mobileContainer.className = "mobile-sidebar-container";
  mobileContainer.innerHTML = `
    <div class="mobile-sidebar-handle">
      <div class="mobile-sidebar-dragger"></div>
    </div>
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
  document.body.appendChild(mobileContainer);
  document.body.appendChild(mobileSearchPopup);

  // Immediately populate mobile sidebar content if desktop sidebar exists
  const desktopSidebar = document.querySelector(".sidebar");
  const mobileSidebarContent = mobileContainer.querySelector(
    ".mobile-sidebar-content",
  );
  if (desktopSidebar && mobileSidebarContent) {
    mobileSidebarContent.innerHTML = desktopSidebar.innerHTML;
  }
}

// Highlight search terms on target pages
function highlightTextInContent(container, terms) {
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
  setTimeout(() => {
    const firstHighlight = container.querySelector(".search-highlight");
    if (firstHighlight) {
      firstHighlight.scrollIntoView({ behavior: "smooth", block: "center" });
      firstHighlight.classList.add("search-highlight-active");
    }
  }, 100);
}

// Initialize scroll spy
function initScrollSpy() {
  const pageToc = document.querySelector(".page-toc");
  if (!pageToc) return;

  const tocLinks = pageToc.querySelectorAll(".page-toc-list a");
  const content = document.querySelector(".content");
  if (!tocLinks.length || !content) return;

  const headings = Array.from(
    content.querySelectorAll("h1[id], h2[id], h3[id]"),
  );

  if (!headings.length) return;

  // Build a map of heading IDs to TOC links for quick lookup
  const linkMap = new Map();
  tocLinks.forEach((link) => {
    const href = link.getAttribute("href");
    if (href && href.startsWith("#")) {
      linkMap.set(href.slice(1), link);
    }
  });

  let activeLink = null;

  // Update active link based on scroll position
  function updateActiveLink() {
    const threshold = 120; // threshold from the top of the viewport

    let currentHeading = null;

    // Find the last heading that is at or above the threshold
    for (const heading of headings) {
      const rect = heading.getBoundingClientRect();
      if (rect.top <= threshold) {
        currentHeading = heading;
      }
    }

    // If no heading is above threshold, use first heading if it's in view
    if (!currentHeading && headings.length > 0) {
      const firstRect = headings[0].getBoundingClientRect();
      if (firstRect.top < window.innerHeight) {
        currentHeading = headings[0];
      }
    }

    const newLink = currentHeading ? linkMap.get(currentHeading.id) : null;

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
  let ticking = false;
  function onScroll() {
    if (!ticking) {
      requestAnimationFrame(() => {
        updateActiveLink();
        ticking = false;
      });
      ticking = true;
    }
  }

  window.addEventListener("scroll", onScroll, { passive: true });

  // Also update on hash change (direct link navigation)
  window.addEventListener("hashchange", () => {
    requestAnimationFrame(updateActiveLink);
  });

  // Set initial active state after a small delay to ensure
  // browser has completed any hash-based scrolling
  setTimeout(updateActiveLink, 100);
}

document.addEventListener("DOMContentLoaded", function () {
  // Apply sidebar state immediately before DOM rendering
  try {
    if (localStorage.getItem("sidebar-collapsed") === "true") {
      document.documentElement.classList.add("sidebar-collapsed");
      document.body.classList.add("sidebar-collapsed");
    }
  } catch {
    // localStorage unavailable
  }

  if (!document.querySelector(".mobile-sidebar-fab")) {
    createMobileElements();
  }

  // Initialize scroll spy for page TOC
  initScrollSpy();

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

      // Initial state check
      if (!details.hasAttribute("open")) {
        sidebarHiddenContainer.content.appendChild(content);
      }
    });

  // Handle sidebar collapse/expand - move entire sidebar to template when collapsed
  const sidebar = document.querySelector(".sidebar");
  const sidebarObserver = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.attributeName === "class") {
        const isCollapsed =
          document.documentElement.classList.contains("sidebar-collapsed");
        if (isCollapsed) {
          // Sidebar collapsed - move to template
          if (sidebar.parentElement) {
            sidebarHiddenContainer.content.appendChild(sidebar);
          }
        } else {
          // Sidebar expanded - move back to DOM
          if (sidebarHiddenContainer.content.contains(sidebar)) {
            const layout = document.querySelector(".layout");
            const contentEl = document.querySelector(".content");
            if (layout) {
              layout.insertBefore(sidebar, contentEl);
            }
          }
        }
      }
    });
  });

  if (sidebar) {
    sidebarObserver.observe(document.documentElement, { attributes: true });

    // Initial state - if collapsed, move sidebar to template
    if (document.documentElement.classList.contains("sidebar-collapsed")) {
      sidebarHiddenContainer.content.appendChild(sidebar);
    }
  }

  // Desktop Sidebar Toggle
  const sidebarToggle = document.querySelector(".sidebar-toggle");

  // On page load, sync the state from `documentElement` to `body`
  if (document.documentElement.classList.contains("sidebar-collapsed")) {
    document.body.classList.add("sidebar-collapsed");
  }

  if (sidebarToggle) {
    sidebarToggle.addEventListener("click", function () {
      // Toggle on both elements for consistency
      document.documentElement.classList.toggle("sidebar-collapsed");
      document.body.classList.toggle("sidebar-collapsed");

      // Use documentElement to check state and save to localStorage
      const isCollapsed =
        document.documentElement.classList.contains("sidebar-collapsed");
      try {
        localStorage.setItem("sidebar-collapsed", isCollapsed);
      } catch {
        // localStorage unavailable
      }
    });
  }

  // Make headings clickable for anchor links
  const content = document.querySelector(".content");
  if (content) {
    const headings = content.querySelectorAll("h1, h2, h3, h4, h5, h6");

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
      heading.addEventListener("click", function () {
        const id = this.id;
        history.pushState(null, null, "#" + id);

        // Scroll with offset
        const offset = this.getBoundingClientRect().top + window.scrollY - 80;
        window.scrollTo({
          top: offset,
          behavior: "smooth",
        });
      });
    });
  }

  // Process footnotes
  if (content) {
    const footnoteContainer = document.querySelector(".footnotes-container");

    // Find all footnote references and create a footnotes section
    const footnoteRefs = content.querySelectorAll('a[href^="#fn"]');
    if (footnoteRefs.length > 0) {
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

  // Copy link functionality
  document.querySelectorAll(".copy-link").forEach(function (copyLink) {
    copyLink.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();

      // Get option ID from parent element
      const option = copyLink.closest(".option");
      const optionId = option.id;

      // Create URL with hash
      const url = new URL(window.location.href);
      url.hash = optionId;

      // Copy to clipboard
      navigator.clipboard
        .writeText(url.toString())
        .then(function () {
          // Show feedback
          const feedback = copyLink.nextElementSibling;
          feedback.style.display = "inline";

          // Hide after 2 seconds
          setTimeout(function () {
            feedback.style.display = "none";
          }, 2000);
        })
        .catch(function (err) {
          console.error("Could not copy link: ", err);
        });
    });
  });

  // Handle initial hash navigation
  function scrollToElement(element) {
    if (element) {
      const offset = element.getBoundingClientRect().top + window.scrollY - 80;
      window.scrollTo({
        top: offset,
        behavior: "smooth",
      });
    }
  }

  if (window.location.hash) {
    const targetElement = document.querySelector(window.location.hash);
    if (targetElement) {
      setTimeout(() => scrollToElement(targetElement), 0);
      // Add highlight class for options page
      if (targetElement.classList.contains("option")) {
        targetElement.classList.add("highlight");
      }
    }
  }

  // Mobile Sidebar Functionality
  const mobileSidebarContainer = document.querySelector(
    ".mobile-sidebar-container",
  );
  const mobileSidebarFab = document.querySelector(".mobile-sidebar-fab");
  const mobileSidebarHandle = document.querySelector(".mobile-sidebar-handle");

  // Always set up FAB if it exists
  if (mobileSidebarFab && mobileSidebarContainer) {
    const openMobileSidebar = () => {
      mobileSidebarContainer.classList.add("active");
      mobileSidebarFab.setAttribute("aria-expanded", "true");
      mobileSidebarContainer.setAttribute("aria-hidden", "false");
      mobileSidebarFab.classList.add("fab-hidden"); // hide FAB when drawer is open
    };

    const closeMobileSidebar = () => {
      mobileSidebarContainer.classList.remove("active");
      mobileSidebarFab.setAttribute("aria-expanded", "false");
      mobileSidebarContainer.setAttribute("aria-hidden", "true");
      mobileSidebarFab.classList.remove("fab-hidden"); // Show FAB when drawer is closed
    };

    mobileSidebarFab.addEventListener("click", (e) => {
      e.stopPropagation();
      if (mobileSidebarContainer.classList.contains("active")) {
        closeMobileSidebar();
      } else {
        openMobileSidebar();
      }
    });

    // Only set up drag functionality if handle exists
    if (mobileSidebarHandle) {
      // Drag functionality
      let isDragging = false;
      let startY = 0;
      let startHeight = 0;

      // Cleanup function for drag interruption
      function cleanupDrag() {
        if (isDragging) {
          isDragging = false;
          mobileSidebarHandle.style.cursor = "grab";
          document.body.style.userSelect = "";
        }
      }

      mobileSidebarHandle.addEventListener("mousedown", (e) => {
        isDragging = true;
        startY = e.pageY;
        startHeight = mobileSidebarContainer.offsetHeight;
        mobileSidebarHandle.style.cursor = "grabbing";
        document.body.style.userSelect = "none"; // prevent text selection
      });

      mobileSidebarHandle.addEventListener("touchstart", (e) => {
        isDragging = true;
        startY = e.touches[0].pageY;
        startHeight = mobileSidebarContainer.offsetHeight;
      });

      document.addEventListener("mousemove", (e) => {
        if (!isDragging) return;
        const deltaY = startY - e.pageY;
        const newHeight = startHeight + deltaY;
        const vh = window.innerHeight;
        const minHeight = vh * 0.15;
        const maxHeight = vh * 0.9;

        if (newHeight >= minHeight && newHeight <= maxHeight) {
          mobileSidebarContainer.style.height = `${newHeight}px`;
        }
      });

      document.addEventListener("touchmove", (e) => {
        if (!isDragging) return;
        const deltaY = startY - e.touches[0].pageY;
        const newHeight = startHeight + deltaY;
        const vh = window.innerHeight;
        const minHeight = vh * 0.15;
        const maxHeight = vh * 0.9;

        if (newHeight >= minHeight && newHeight <= maxHeight) {
          mobileSidebarContainer.style.height = `${newHeight}px`;
        }
      });

      document.addEventListener("mouseup", cleanupDrag);
      document.addEventListener("touchend", cleanupDrag);
      window.addEventListener("blur", cleanupDrag);
      document.addEventListener("visibilitychange", function () {
        if (document.hidden) cleanupDrag();
      });
    }

    // Close on outside click
    document.addEventListener("click", (event) => {
      if (
        mobileSidebarContainer.classList.contains("active") &&
        !mobileSidebarContainer.contains(event.target) &&
        !mobileSidebarFab.contains(event.target)
      ) {
        closeMobileSidebar();
      }
    });

    // Close on escape key
    document.addEventListener("keydown", (event) => {
      if (
        event.key === "Escape" &&
        mobileSidebarContainer.classList.contains("active")
      ) {
        closeMobileSidebar();
      }
    });
  }

  // Options filter functionality
  const optionsFilter = document.getElementById("options-filter");
  if (optionsFilter) {
    const optionsContainer = document.querySelector(".options-container");
    if (!optionsContainer) return;

    // Template container for hidden options
    const hiddenOptionsContainer = document.createElement("template");
    hiddenOptionsContainer.id = "hidden-options-container";
    document.body.appendChild(hiddenOptionsContainer);

    // Create filter results counter
    const filterResults = document.createElement("div");
    filterResults.className = "filter-results";
    optionsFilter.parentNode.insertBefore(
      filterResults,
      optionsFilter.nextSibling,
    );

    // Detect if we're on a mobile device
    const isMobile =
      window.innerWidth < 768 || /Mobi|Android/i.test(navigator.userAgent);

    // Cache all option elements and their searchable content
    const options = Array.from(document.querySelectorAll(".option"));
    const totalCount = options.length;

    // Store the original order of option elements
    const originalOptionOrder = options.slice();

    // Pre-process and optimize searchable content
    const optionsData = options.map((option) => {
      const nameElem = option.querySelector(".option-name");
      const descriptionElem = option.querySelector(".option-description");
      const id = option.id ? option.id.toLowerCase() : "";
      const name = nameElem ? nameElem.textContent.toLowerCase() : "";
      const description = descriptionElem
        ? descriptionElem.textContent.toLowerCase()
        : "";

      // Extract keywords for faster searching
      const keywords = (id + " " + name + " " + description)
        .toLowerCase()
        .split(/\s+/)
        .filter((word) => word.length > 1);

      return {
        element: option,
        id,
        name,
        description,
        keywords,
        searchText: (id + " " + name + " " + description).toLowerCase(),
      };
    });

    // Chunk size and rendering variables
    const CHUNK_SIZE = isMobile ? 15 : 40;
    let pendingRender = null;
    let currentChunk = 0;
    let itemsToProcess = [];

    function debounce(func, wait) {
      let timeout;
      return function () {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), wait);
      };
    }

    // Process options in chunks to prevent UI freezing
    function processNextChunk() {
      const startIdx = currentChunk * CHUNK_SIZE;
      const endIdx = Math.min(startIdx + CHUNK_SIZE, itemsToProcess.length);

      if (startIdx < itemsToProcess.length) {
        // Move visible items to container, hide others
        for (let i = startIdx; i < endIdx; i++) {
          const item = itemsToProcess[i];
          if (item.visible) {
            optionsContainer.appendChild(item.element);
          } else {
            hiddenOptionsContainer.content.appendChild(item.element);
          }
        }

        currentChunk++;
        pendingRender = requestAnimationFrame(processNextChunk);
      } else {
        pendingRender = null;
        currentChunk = 0;
        itemsToProcess = [];

        if (filterResults.visibleCount !== undefined) {
          if (filterResults.visibleCount < totalCount) {
            filterResults.textContent = `Showing ${filterResults.visibleCount} of ${totalCount} options`;
            filterResults.style.display = "block";
          } else {
            filterResults.style.display = "none";
          }
        }
      }
    }

    // Initialize: keep all options visible by default
    // They will be moved to hidden container only when filtering
    function filterOptions() {
      const searchTerm = optionsFilter.value.toLowerCase().trim();

      // Skip if search term hasn't changed
      if (filterOptions.lastTerm === searchTerm) {
        return;
      }
      filterOptions.lastTerm = searchTerm;

      if (pendingRender) {
        cancelAnimationFrame(pendingRender);
        pendingRender = null;
      }
      currentChunk = 0;
      itemsToProcess = [];

      if (searchTerm === "") {
        // Restore to original order
        const fragment = document.createDocumentFragment();
        originalOptionOrder.forEach((option) => {
          hiddenOptionsContainer.content.appendChild(option);
        });
        while (hiddenOptionsContainer.content.firstChild) {
          fragment.appendChild(hiddenOptionsContainer.content.firstChild);
        }
        optionsContainer.appendChild(fragment);
        filterResults.style.display = "none";
        return;
      }

      const searchTerms = searchTerm
        .split(/\s+/)
        .filter((term) => term.length > 0);
      let visibleCount = 0;

      const titleMatches = [];
      const descMatches = [];
      const term = searchTerms[0];

      for (let i = 0; i < optionsData.length; i++) {
        const data = optionsData[i];
        const isTitleMatch = data.name.includes(term);
        const isDescMatch = !isTitleMatch && data.description.includes(term);

        if (isTitleMatch) {
          visibleCount++;
          titleMatches.push(data);
        } else if (isDescMatch) {
          visibleCount++;
          descMatches.push(data);
        }
      }

      titleMatches.sort((a, b) => a.name.indexOf(term) - b.name.indexOf(term));
      descMatches.sort(
        (a, b) => a.description.indexOf(term) - b.description.indexOf(term),
      );

      const visibleElements = new Set();
      itemsToProcess = [];
      for (let i = 0; i < titleMatches.length; i++) {
        const data = titleMatches[i];
        visibleElements.add(data.element);
        itemsToProcess.push({ element: data.element, visible: true });
      }
      for (let i = 0; i < descMatches.length; i++) {
        const data = descMatches[i];
        visibleElements.add(data.element);
        itemsToProcess.push({ element: data.element, visible: true });
      }
      for (let i = 0; i < optionsData.length; i++) {
        const data = optionsData[i];
        if (!visibleElements.has(data.element)) {
          itemsToProcess.push({ element: data.element, visible: false });
        }
      }

      // Reorder DOM so all title matches, then desc matches, then hidden
      const fragment = document.createDocumentFragment();
      for (let i = 0; i < itemsToProcess.length; i++) {
        fragment.appendChild(itemsToProcess[i].element);
      }
      optionsContainer.appendChild(fragment);

      filterResults.visibleCount = visibleCount;
      pendingRender = requestAnimationFrame(processNextChunk);
    }

    // Use different debounce times for desktop vs mobile
    const debouncedFilter = debounce(filterOptions, isMobile ? 200 : 100);

    // Set up event listeners
    optionsFilter.addEventListener("input", debouncedFilter);

    // Allow clearing with Escape key
    optionsFilter.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        optionsFilter.value = "";
        filterOptions();
      }
    });

    // Handle visibility changes
    document.addEventListener("visibilitychange", function () {
      if (!document.hidden && optionsFilter.value) {
        filterOptions();
      }
    });

    // Run initial filter if there's a value
    if (optionsFilter.value) {
      filterOptions();
    }

    // Pre-calculate heights for smoother scrolling
    if (isMobile && totalCount > 50) {
      requestIdleCallback(() => {
        const sampleOption = options[0];
        if (sampleOption) {
          const height = sampleOption.offsetHeight;
          if (height > 0) {
            options.forEach((opt) => {
              opt.style.containIntrinsicSize = `0 ${height}px`;
            });
          }
        }
      });
    }
  }

  // Lib filter functionality
  const libFilter = document.getElementById("lib-filter");
  if (libFilter && document.querySelector(".lib-container")) {
    const libContainer = document.querySelector(".lib-container");

    const hiddenLibContainer = document.createElement("template");
    hiddenLibContainer.id = "hidden-lib-container";
    document.body.appendChild(hiddenLibContainer);

    const filterResults = document.createElement("div");
    filterResults.className = "filter-results";
    libFilter.parentNode.insertBefore(filterResults, libFilter.nextSibling);

    const isMobile =
      window.innerWidth < 768 || /Mobi|Android/i.test(navigator.userAgent);

    const libEntries = Array.from(document.querySelectorAll(".lib-entry"));
    const totalCount = libEntries.length;
    const originalLibOrder = libEntries.slice();

    const libData = libEntries.map((entry) => {
      const nameElem = entry.querySelector(".lib-entry-name");
      const descriptionElem = entry.querySelector(".lib-entry-description");
      const id = entry.id ? entry.id.toLowerCase() : "";
      const name = nameElem ? nameElem.textContent.toLowerCase() : "";
      const description = descriptionElem
        ? descriptionElem.textContent.toLowerCase()
        : "";

      const keywords = (id + " " + name + " " + description)
        .toLowerCase()
        .split(/\s+/)
        .filter((word) => word.length > 1);

      return {
        element: entry,
        id,
        name,
        description,
        keywords,
        searchText: (id + " " + name + " " + description).toLowerCase(),
      };
    });

    const CHUNK_SIZE = isMobile ? 15 : 40;
    let pendingRender = null;
    let currentChunk = 0;
    let itemsToProcess = [];

    function debounceLib(func, wait) {
      let timeout;
      return function () {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), wait);
      };
    }

    function processNextChunkLib() {
      const startIdx = currentChunk * CHUNK_SIZE;
      const endIdx = Math.min(startIdx + CHUNK_SIZE, itemsToProcess.length);

      if (startIdx < itemsToProcess.length) {
        for (let i = startIdx; i < endIdx; i++) {
          const item = itemsToProcess[i];
          if (item.visible) {
            libContainer.appendChild(item.element);
          } else {
            hiddenLibContainer.content.appendChild(item.element);
          }
        }

        currentChunk++;
        pendingRender = requestAnimationFrame(processNextChunkLib);
      } else {
        pendingRender = null;
        currentChunk = 0;
        itemsToProcess = [];

        if (filterResults.visibleCount !== undefined) {
          if (filterResults.visibleCount < totalCount) {
            filterResults.textContent = `Showing ${filterResults.visibleCount} of ${totalCount} functions`;
            filterResults.style.display = "block";
          } else {
            filterResults.style.display = "none";
          }
        }
      }
    }

    function filterLib() {
      const searchTerm = libFilter.value.toLowerCase().trim();

      if (filterLib.lastTerm === searchTerm) {
        return;
      }
      filterLib.lastTerm = searchTerm;

      if (pendingRender) {
        cancelAnimationFrame(pendingRender);
        pendingRender = null;
      }
      currentChunk = 0;
      itemsToProcess = [];

      if (searchTerm === "") {
        const fragment = document.createDocumentFragment();
        originalLibOrder.forEach((entry) => {
          hiddenLibContainer.content.appendChild(entry);
        });
        while (hiddenLibContainer.content.firstChild) {
          fragment.appendChild(hiddenLibContainer.content.firstChild);
        }
        libContainer.appendChild(fragment);
        filterResults.style.display = "none";
        return;
      }

      const searchTerms = searchTerm
        .split(/\s+/)
        .filter((term) => term.length > 0);
      let visibleCount = 0;

      const titleMatches = [];
      const descMatches = [];
      const term = searchTerms[0];

      for (let i = 0; i < libData.length; i++) {
        const data = libData[i];
        const isTitleMatch = data.name.includes(term);
        const isDescMatch = !isTitleMatch && data.description.includes(term);

        if (isTitleMatch) {
          visibleCount++;
          titleMatches.push(data);
        } else if (isDescMatch) {
          visibleCount++;
          descMatches.push(data);
        }
      }

      titleMatches.sort((a, b) => a.name.indexOf(term) - b.name.indexOf(term));
      descMatches.sort(
        (a, b) => a.description.indexOf(term) - b.description.indexOf(term),
      );

      const visibleElements = new Set();
      itemsToProcess = [];
      for (let i = 0; i < titleMatches.length; i++) {
        const data = titleMatches[i];
        visibleElements.add(data.element);
        itemsToProcess.push({ element: data.element, visible: true });
      }
      for (let i = 0; i < descMatches.length; i++) {
        const data = descMatches[i];
        visibleElements.add(data.element);
        itemsToProcess.push({ element: data.element, visible: true });
      }
      for (let i = 0; i < libData.length; i++) {
        const data = libData[i];
        if (!visibleElements.has(data.element)) {
          itemsToProcess.push({ element: data.element, visible: false });
        }
      }

      const fragment = document.createDocumentFragment();
      for (let i = 0; i < itemsToProcess.length; i++) {
        fragment.appendChild(itemsToProcess[i].element);
      }
      libContainer.appendChild(fragment);

      filterResults.visibleCount = visibleCount;
      pendingRender = requestAnimationFrame(processNextChunkLib);
    }

    const debouncedFilter = debounceLib(filterLib, isMobile ? 200 : 100);

    libFilter.addEventListener("input", debouncedFilter);

    libFilter.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        libFilter.value = "";
        filterLib();
      }
    });

    document.addEventListener("visibilitychange", function () {
      if (!document.hidden && libFilter.value) {
        filterLib();
      }
    });

    if (libFilter.value) {
      filterLib();
    }

    if (isMobile && totalCount > 50) {
      requestIdleCallback(() => {
        const sampleEntry = libEntries[0];
        if (sampleEntry) {
          const height = sampleEntry.offsetHeight;
          if (height > 0) {
            libEntries.forEach((entry) => {
              entry.style.containIntrinsicSize = `0 ${height}px`;
            });
          }
        }
      });
    }
  }

  // URL-based search highlighting
  const urlParams = new URLSearchParams(window.location.search);
  const highlightQuery = urlParams.get("highlight");
  if (highlightQuery && content) {
    // Simple tokenizer that doesn't depend on search engine
    const queryTerms = highlightQuery
      .toLowerCase()
      .trim()
      .split(/\s+/)
      .filter((term) => term.length >= 2); // min 2 chars like search engine

    if (queryTerms.length > 0) {
      highlightTextInContent(content, queryTerms);
    }
  }
});
