/*

       SuperCollider Tutorial: 9. MIDI
       https://www.youtube.com/watch?v=Oz4KYZ9KLc0

       the basics of getting SC to communicate with MIDI
       read guides: 'Using MIDI' and 'MIDI'

*/

s.boot;

// ask your OS, see postwindow, what midi devices are connected to your HW.
MIDIClient.init;

// Easiest way to connect, connects to all available devices
MIDIIn.connectAll;

// but you can connect explicitely
MIDIClient.sources;  //gets array of available
MIDIIn.connect(index in above array);

// just like with Synths we can use a class to register an action to be taken
// when a certain type of midi message is received. MIDIdef and MIDIfunc.
// MIDIdef is a subclass of MIDIFunc, they both expose very similar functionality.
// We'll focus on MIDIdef only.


