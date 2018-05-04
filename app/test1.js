function getPageItemIndex(page, itemsPerPage, itemLength) {
    var startIndex = page * itemsPerPage;
    if (startIndex >= itemLength) {
        console.log("Page Exceeds");
        return;
    }

    var itemsToRead = itemLength - startIndex;
    if (itemsToRead > itemsPerPage)
        itemsToRead = itemsPerPage;
    var endIndex = startIndex + (itemsToRead-1);

    console.log("startIndex :", startIndex);
    console.log("endIndex : ", endIndex);
    console.log("itemsToRead :", itemsToRead);
}


getPageItemIndex(0, 10, 2);