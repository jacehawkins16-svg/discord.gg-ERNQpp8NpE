(function() {
    // Get the current filename from the URL path
    const currentPage = window.location.pathname.split("/").pop();

    // Define the page you want everyone to stay on
    const destination = "index.html";

    // If the current page is NOT index.html and is NOT empty (the root)
    if (currentPage !== destination && currentPage !== "") {
        window.location.href = destination;
    }
})();
