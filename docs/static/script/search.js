document.addEventListener("DOMContentLoaded", () => {
  if (!window.location.pathname.endsWith("options.html")) return;

  const searchBar = document.createDocumentFragment();
  const searchDiv = document.createElement("div");
  searchDiv.id = "search-bar";
  searchDiv.innerHTML = `
    <input type="text" id="search-input" placeholder="Search options by ID..." />
    <div id="search-results"></div>
  `;
  searchBar.appendChild(searchDiv);
  document.body.prepend(searchDiv);

  const dtElements = Array.from(document.querySelectorAll("dt"));
  const ddElements = Array.from(document.querySelectorAll("dd"));
  const dtOptionIds = dtElements.map(
    (dt) => dt.querySelector("a")?.id.toLowerCase() || "",
  );

  if (dtElements.length === 0 || ddElements.length === 0) {
    console.warn("Something went wrong, page may be loaded incorrectly.");
    return;
  }

  let debounceTimeout;
  document.getElementById("search-input").addEventListener("input", (event) => {
    clearTimeout(debounceTimeout);
    debounceTimeout = setTimeout(() => {
      const query = event.target.value.toLowerCase();
      dtElements.forEach((dt, index) => {
        const isMatch = dtOptionIds[index].includes(query);

        if (dt.classList.contains("hidden") !== !isMatch) {
          dt.classList.toggle("hidden", !isMatch);
          ddElements[index]?.classList.toggle("hidden", !isMatch);
        }
      });
    }, 200);
  });
});
