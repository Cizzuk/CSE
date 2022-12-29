var isBoldText = false;
function isBoldTextEnabled (bool) {isBoldText = bool;}
var buttonShapes = false;
function buttonShapesEnabled (bool) {buttonShapes = bool;}

function accessibilityUpdate() {
	if (isBoldText == true) {
		$('*').css('font-weight', 'bold');
	}else{
		$('*').css('font-weight', '');
	}
	if (buttonShapes == true) {
		$('a').css('text-decoration', 'underline');
		$('button').css('text-decoration', 'underline');
	}else{
		$('a').css('text-decoration', '');
		$('button').css('text-decoration', '');
	}
window.setTimeout("accessibilityUpdate();", 100);
}
accessibilityUpdate();
