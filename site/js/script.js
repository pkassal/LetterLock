var stack = [];
var pzlNum=0;
var pzlSrc;
var key;
var correctMark = "\u2713 Correct!";
var incorrectMark = " ";

function randPuzzle() {
    random_num=(Math.floor(Math.random()*allPuzzles.length)); 
    pzl(random_num);
}

function pzl(num) { pzlNum=num; buildPage(); }

function buildPage() {
    pzlSrc= allPuzzles[pzlNum];
    var e = document.getElementById("difficulty");
    var difficulty = e.options[e.selectedIndex].value;
    key = pzlSrc["keys"][difficulty];
    showPuzzleNumber();
    showCategories();
    buildPuzzle();
}

function buildPuzzle() {
    var puzzleElem = document.getElementById("thepuzzle");
    push(puzzleElem); removeAllChildren();
    showInstructions();
    for (var a=0; a<pzlSrc["answers"].length; a++) {
	push("line"); classedSpan(); 
	var answer = pzlSrc["answers"][a];
	push(answer); buildTableau(); append();
	push(answer); buildSide(); append();
	append();
    }
    pop();
}

function showPuzzleNumber() { 
    push(document.getElementById("puzzleNum"));
    removeAllChildren();
    push(pzlSrc["pindex"]); text(); append();
    pop();
}

function showCategories() {
    push(document.getElementById("categories"));
    removeAllChildren();
    var categoryList = pzlSrc["cats"].join(", ");
    push(categoryList); text(); append();
    pop();
}

function showInstructions() {
    line(); 

    puzzleLine(); 
    instructions();  push("Colored boxes have matching letters. Black boxes already have the correct letter.  Click on a box and type a letter."); 
    text(); append(); append();
    append();

    sideLine();
    instructions(); push("These letters appear somewhere on that line in a white box."); text(); append(); append(); 
    append();

    append();
}

function buildSide() {
    findSideLetters(); sortArray();
    var sortedLetters = pop();
    sideLine();
    for (var letter in sortedLetters) {
	span(); push(sortedLetters[letter]); text(); append();
	append(); 	
    }
}

function findSideLetters() {
    var answer = pop();
    var sideSet = new Array();
    for (var i=0; i<answer.length; i++) {
	var c = answer.charAt(i).toUpperCase();
	var k = (c==' ')?'space':key.charAt(c.charCodeAt(0)-65);
	if (k=='s') {
	    sideSet[c]=1;
	}
    } 
    push(sideSet);
}

function sortArray() {
    var sideSet = pop();
    var sortedLetters = [];
    for (var letter in sideSet) {
	sortedLetters.push(letter);
    }
    sortedLetters.sort();
    push(sortedLetters);
}

function buildTableau() {
    var answer = pop();
    puzzleLine();
    for (var i=0; i<answer.length; i++) {
	var c = answer.charAt(i).toUpperCase();
	var k = (c==' ')?'space':key.charAt(c.charCodeAt(0)-65);
	var toShow;
	if (c==' ') { toShow=' '; }
	else if (k=='i') { toShow=c; }
	else { toShow=""; }
	
	if ( toShow==" " ) { push(" "); text(); } 
	else {
	    input(); oneWide();
	    push(toShow); value(); 
	    stack.push(k); asColorStyle();
	    forceUppercase(); 
	    if (k=='i' || c==' ') { readOnly(); }
	    push(c); assignCorrectAnswer();
	    assignChangeHandling();
	}
	append();	
    }
    addCorrectMarkRegion(); 
    setupLineChecking();
    append();
}

function addCorrectMarkRegion() {
    push("correctMark"); classedSpan(); push(incorrectMark); text(); append();
}

function setupLineChecking() {
    var region = pop();
    var line = pop();
    line.checkIfAllCorrect = function () {
	for (var i=0;i<line.childNodes.length-1;i++) {
	    var nownode=line.childNodes[i];
	    if (!nownode.isCorrect()) {
//		console.log("Child["+i+"] is '"+nownode.value+"' and not '"+nownode.correctValue+"'");
		return;
	    }
	}
	region.innerHTML = correctMark;
    }
    line.oneIsWrong = function() { 
	region.innerHTML = incorrectMark;
    }
    push(line); push(region);
}

function assignCorrectAnswer() { 
    var correctValue=pop();
    var e=pop();
    e.correctValue=correctValue;
    e.isCorrect=function() { return e.value.toUpperCase()==e.correctValue.toUpperCase(); }
    push(e);
}


function assignChangeHandling() {
    var e=pop();
    var numberedClasses = ['ltr0', 'ltr1', 'ltr2', 'ltr3', 'ltr4', 'ltr5', 'ltr6', 'ltr7', 'ltr8', 'ltr9'];
    e.updateLine = function() {
	var parent = e.parentNode;
	if (e.isCorrect()) {
	    parent.checkIfAllCorrect();
	} else {
	    parent.oneIsWrong();
	}	
    }
    e.onchange = function() { 
	if (numberedClasses.indexOf(e.className)!=-1) {
	    var sameColoredBoxes = document.getElementsByClassName(e.className);
	    for (var i=0; i<sameColoredBoxes.length; i++) {		
		sameColoredBoxes[i].value=e.value;
		sameColoredBoxes[i].updateLine();
	    }
	} else {
	    e.updateLine();
	}
    }
    push(e);
}

function cheater() {
    
}

function sideLine() { push("sideline"); classedSpan(); }
function puzzleLine() { push("puzzleline"); classedSpan(); }
function instructions() { push("instructions"); classedSpan(); }
function asColorStyle() { var n=pop(); push("ltr"+n); assignClass(); }
function line() { div(); push("line"); assignClass(); }
function assignClass() { var c=pop(); var e=pop(); e.setAttribute("class",c); push(e); }
function assignId() { var id=pop(); var e=pop(); e.setAttribute("id",id); push(e); }
function classedSpan() { var c=pop(); span(); push(c); assignClass(); }

function append() { var e=pop(); var parent=pop(); parent.appendChild(e); push(parent); }
function push(x) { stack.push(x); }
function pop() { return stack.pop(); }
function dup() { var t=pop(); push(t); push(t); }
function backrot() { var w3=pop(); var w2=pop(); var w1=pop(); 
		     push(w3); push(w2); push(w1); }
function swap() { var w2=pop(); var w1=pop(); push(w2); push(w1); }

function element() {
    var node = document.createElement(pop());
    push(node);
}

function removeAllChildren() {
    var e = pop();
    if ( e.hasChildNodes() ) {
	while ( e.childNodes.length >= 1 ) {
            e.removeChild( e.firstChild );       
	} 
    }
    push(e);
}

function input() { push("input"); element(); }
function div()  { push("div"); element(); }
function span() { push("span"); element(); }
function text() { push(document.createTextNode(pop())); }
function value() { var v=pop(); var e=pop(); e.value=v; push(e); }
function oneWide() { var s=1; var e=pop(); e.maxLength=s; e.size=s; e.style.width=s+"em"; push(e); }
function readOnly() { var e=pop(); e.readOnly='1'; push(e); }
function forceUppercase() { var e=pop(); e.style.textTransform="uppercase"; push(e); }


