/*
    Dynamixel Javascript File

    Filename:
    Author:
    Date:

*/

var pos=512;
var step=300;
var servoID=1;

console.log('start timer');
setInterval( function() {

	console.log('pos: ' +pos);
    D.setSpeedOfServo( 1000, servoID );
	D.setPositionOfServo( pos, servoID );
	pos+=step;

	if( pos >= 812  || pos <= 212 ) {
		step = -step;
	} 

},1000);
