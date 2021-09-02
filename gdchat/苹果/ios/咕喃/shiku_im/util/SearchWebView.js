// We're using a global variable to store the number of occurrences
var MyApp_SearchResultCount = 0;
var scrollIndex = 0;
var keywordNum;
var clickTime = 0;
var keywordBox = new Array();


// helper function, recursively searches in elements and their child nodes
function MyApp_HighlightAllOccurencesOfStringForElement(element,keyword) {
    if (element) {
        if (element.nodeType == 3) {        // Text node
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.toLowerCase().indexOf(keyword);
                
                if (idx < 0) break;             // not found, abort
                
                var span = document.createElement("span");
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                span.setAttribute("class","MyAppHighlight");
                span.style.backgroundColor="yellow";
                span.style.color="black";
                text = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
                
                if(span.offsetTop == 0){
                    return;
                }
                
                keywordBox.push(span);
                
                MyApp_SearchResultCount++;    // update the counter
            }
        }
        else if (element.nodeType == 1) { // Element node
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    MyApp_HighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}

function getPosition(e) {
    var t = e.offsetTop;
    var l = e.offsetLeft;
    var w = e.offsetWidth;
    var h = e.offsetHeight-1;
    while(e=e.offsetParent) {
        t+=e.offsetTop;
        l+=e.offsetLeft;
    }
    scrollTo(l,t-60);
}


// the main entry point to start the search
function MyApp_HighlightAllOccurencesOfString(keyword, index) {
    MyApp_RemoveAllHighlights();
    clickTime = parseInt(index);
    keywordNum = 0;
    keywordBox = new Array();
    MyApp_HighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
    var arrLength = keywordBox.length;
    getPosition(keywordBox[arrLength-index]);
    
    return arrLength;
}

// helper function, recursively removes the highlights in elements and their childs
function MyApp_RemoveAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == "MyAppHighlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (MyApp_RemoveAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                
                if (normalize) {
                    element.normalize();
                }
            }
        }
        
    }
    return false;
}

// the main entry point to remove the highlights
function MyApp_RemoveAllHighlights() {
    MyApp_SearchResultCount = 0;
    MyApp_RemoveAllHighlightsForElement(document.body);
}



