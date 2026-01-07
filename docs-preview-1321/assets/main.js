// Polyfill for requestIdleCallback for Safari and unsupported browsers
if (typeof window.requestIdleCallback === "undefined") {
  window.requestIdleCallback = function (cb) {
    var start = Date.now();
    var idlePeriod = 50;
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
  mobileSearchPopup.innerHTML = `
    <div class="mobile-search-container">
      <div class="mobile-search-header">
        <input type="text" id="mobile-search-input" placeholder="Search..." />
        <button id="close-mobile-search" class="close-mobile-search" aria-label="Close search">&times;</button>
      </div>
      <div id="mobile-search-results" class="mobile-search-results"></div>
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

document.addEventListener("DOMContentLoaded", function () {
  // Apply sidebar state immediately before DOM rendering
  if (localStorage.getItem("sidebar-collapsed") === "true") {
    document.documentElement.classList.add("sidebar-collapsed");
    document.body.classList.add("sidebar-collapsed");
  }

  if (!document.querySelector(".mobile-sidebar-fab")) {
    createMobileElements();
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
      localStorage.setItem("sidebar-collapsed", isCollapsed);
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
      heading.addEventListener("click", function (e) {
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
  const mobileSidebarContent = document.querySelector(
    ".mobile-sidebar-content",
  );
  const mobileSidebarHandle = document.querySelector(".mobile-sidebar-handle");
  const desktopSidebar = document.querySelector(".sidebar");

  // Always set up FAB if it exists
  if (mobileSidebarFab && mobileSidebarContainer) {
    // Populate content if desktop sidebar exists
    if (desktopSidebar && mobileSidebarContent) {
      mobileSidebarContent.innerHTML = desktopSidebar.innerHTML;
    }

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

    // Only inject the style if it doesn't already exist
    if (!document.head.querySelector("style[data-options-hidden]")) {
      const styleEl = document.createElement("style");
      styleEl.setAttribute("data-options-hidden", "");
      styleEl.textContent = ".option-hidden{display:none!important}";
      document.head.appendChild(styleEl);
    }

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
        // Process current chunk
        for (let i = startIdx; i < endIdx; i++) {
          const item = itemsToProcess[i];
          if (item.visible) {
            item.element.classList.remove("option-hidden");
          } else {
            item.element.classList.add("option-hidden");
          }
        }

        currentChunk++;
        pendingRender = requestAnimationFrame(processNextChunk);
      } else {
        // Finished processing all chunks
        pendingRender = null;
        currentChunk = 0;
        itemsToProcess = [];

        // Update counter at the very end for best performance
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

    function filterOptions() {
      const searchTerm = optionsFilter.value.toLowerCase().trim();

      if (pendingRender) {
        cancelAnimationFrame(pendingRender);
        pendingRender = null;
      }
      currentChunk = 0;
      itemsToProcess = [];

      if (searchTerm === "") {
        // Restore original DOM order when filter is cleared
        const fragment = document.createDocumentFragment();
        originalOptionOrder.forEach((option) => {
          option.classList.remove("option-hidden");
          fragment.appendChild(option);
        });
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
      optionsData.forEach((data) => {
        let isTitleMatch = false;
        let isDescMatch = false;
        if (searchTerms.length === 1) {
          const term = searchTerms[0];
          isTitleMatch = data.name.includes(term);
          isDescMatch = !isTitleMatch && data.description.includes(term);
        } else {
          isTitleMatch = searchTerms.every((term) => data.name.includes(term));
          isDescMatch =
            !isTitleMatch &&
            searchTerms.every((term) => data.description.includes(term));
        }
        if (isTitleMatch) {
          titleMatches.push(data);
        } else if (isDescMatch) {
          descMatches.push(data);
        }
      });

      if (searchTerms.length === 1) {
        const term = searchTerms[0];
        titleMatches.sort(
          (a, b) => a.name.indexOf(term) - b.name.indexOf(term),
        );
        descMatches.sort(
          (a, b) => a.description.indexOf(term) - b.description.indexOf(term),
        );
      }

      itemsToProcess = [];
      titleMatches.forEach((data) => {
        visibleCount++;
        itemsToProcess.push({ element: data.element, visible: true });
      });
      descMatches.forEach((data) => {
        visibleCount++;
        itemsToProcess.push({ element: data.element, visible: true });
      });
      optionsData.forEach((data) => {
        if (!itemsToProcess.some((item) => item.element === data.element)) {
          itemsToProcess.push({ element: data.element, visible: false });
        }
      });

      // Reorder DOM so all title matches, then desc matches, then hidden
      const fragment = document.createDocumentFragment();
      itemsToProcess.forEach((item) => {
        fragment.appendChild(item.element);
      });
      optionsContainer.appendChild(fragment);

      filterResults.visibleCount = visibleCount;
      pendingRender = requestAnimationFrame(processNextChunk);
    }

    // Use different debounce times for desktop vs mobile
    const debouncedFilter = debounce(filterOptions, isMobile ? 200 : 100);

    // Set up event listeners
    optionsFilter.addEventListener("input", debouncedFilter);
    optionsFilter.addEventListener("change", filterOptions);

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

    // Initially trigger filter if there's a value
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
});
