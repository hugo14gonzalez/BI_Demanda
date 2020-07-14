function getDocMaxHeight(doc) {
    doc = doc || document;
    var body = doc.body;
    var html = doc.documentElement;
    var height = Math.max(body.clientHeight, body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
    return height;
}

function resizeIframeHeight(obj) {
    // var doc = obj.contentDocument ? obj.contentDocument : obj.contentWindow.document; 
    var doc = obj.contentDocument;
    obj.style.height = getDocMaxHeight(doc) + "px";
}

