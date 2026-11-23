if (typeof importScripts === "function" && !self.searchCore) {
  importScripts("search-core.js");
}

let searchConfig = self.searchCore.defaultConfig();
let processedDocs = [];

const setDocuments = (data) => {
  searchConfig = self.searchCore.normalizeConfig(data?.config);
  if (Array.isArray(data?.preparedDocuments)) {
    processedDocs = data.preparedDocuments;
    return;
  }

  const documents =
    typeof data?.documents === "string"
      ? JSON.parse(data.documents)
      : data?.documents;
  processedDocs = self.searchCore.prepareDocuments(documents);
};

self.onmessage = function (e) {
  const { messageId, type, data } = e.data;

  const respond = (responseType, responseData) => {
    self.postMessage({ messageId, type: responseType, data: responseData });
  };

  const respondError = (error) => {
    self.postMessage({
      messageId,
      type: "error",
      error: error.message || String(error),
    });
  };

  try {
    if (!self.searchCore) {
      throw new Error("search-core.js is not loaded");
    }

    if (type === "init") {
      setDocuments(data);
      return;
    }

    if (type === "tokenize") {
      respond(
        "tokens",
        self.searchCore.tokenizeQuery(
          typeof data === "string" ? data : "",
          searchConfig,
        ),
      );
      return;
    }

    if (type === "search") {
      const { query, limit = 10 } = data || {};

      if (!query || typeof query !== "string") {
        respond("results", []);
        return;
      }

      if (
        data.documents !== undefined ||
        data.preparedDocuments !== undefined
      ) {
        setDocuments(data);
      }

      respond(
        "results",
        self.searchCore.runSearch(processedDocs, query, limit, searchConfig),
      );
    }
  } catch (error) {
    respondError(error);
  }
};
