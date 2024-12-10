document.addEventListener("DOMContentLoaded", () => {
  if (!window.location.pathname.endsWith("options.html")) return;

  const searchDiv = document.createElement("div");
  searchDiv.id = "search-bar";
  searchDiv.innerHTML = `
    <input type="text" id="search-input" placeholder="Search options by ID..." />
    <div id="search-results"></div>
  `;
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

  const dtElementsData = dtElements.map((dt, index) => ({
    element: dt,
    id: dtOptionIds[index],
    ddElement: ddElements[index],
  }));

  const hiddenClass = "hidden";
  const hiddenStyle = document.createElement("style");
  hiddenStyle.innerHTML = `.${hiddenClass} { display: none; }`;
  document.head.appendChild(hiddenStyle);

  let debounceTimeout;
  document.getElementById("search-input").addEventListener("input", (event) => {
    clearTimeout(debounceTimeout);
    debounceTimeout = setTimeout(() => {
      const query = event.target.value.toLowerCase();

      const matches = [];
      const nonMatches = [];

      dtElementsData.forEach(({ element, id, ddElement }) => {
        const isMatch = id.includes(query);
        if (isMatch) {
          matches.push(element, ddElement);
        } else {
          nonMatches.push(element, ddElement);
        }
      });

      requestAnimationFrame(() => {
        matches.forEach((el) => el?.classList.remove(hiddenClass));
        nonMatches.forEach((el) => el?.classList.add(hiddenClass));
      });
    }, 200);
  });
});
