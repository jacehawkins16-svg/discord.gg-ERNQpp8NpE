(function() {
    // Get the current filename from the URL path
    const currentPage = window.location.pathname.split("/").pop();

    // Define the destination
    const destination = "index.html";

    // Check if the current page is empty (root), index.html, or the destination itself
    // This prevents an infinite redirect loop.
    if (currentPage !== destination && currentPage !== "") {
        window.location.href = destination;
    }
})();
