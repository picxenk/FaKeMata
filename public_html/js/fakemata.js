var noteSequence = [];
var cNote, pNote;
var safeCounter = 0;
var seqNumber = 8;
var ruleMap = {
    "C" : 1,
    "D" : 2,
    "E" : 3,
    "F" : 4,
    "G" : 5,
    "A" : 6,
    "B" : 7,
};
var ruleBirth = [3];
var ruleSurvive = [2, 3];
var ruleColor = [];

function updateNoteSequence() {
    pNote = cNote;
    cNote = noteElem.innerHTML;

    if (pNote == cNote && cNote != '--') {
        if (safeCounter == 4) {
            console.log(cNote);
            if (noteSequence.length >= seqNumber) {
                noteSequence = [];
            }
                noteSequence.push(cNote);
            if (noteSequence.length == seqNumber) {
                console.log("trigger step");
                Processing.getInstanceById('sketch').stepGOL();
            }
        }
        safeCounter++;
    } else {
        safeCounter = 0;
    }
    showNoteSequence();
}


function showNoteSequence() {
    var noteSeqText = document.getElementById("note_sequence");
    noteSeqText.value = noteSequence.join(", ");
}

