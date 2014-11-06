/*

       SuperCollider Tutorial: 9. MIDI
       https://www.youtube.com/watch?v=Oz4KYZ9KLc0

       the basics of getting SC to interpret MIDI
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


/*
       1. Create a MIDIDef to respond to noteOn.
*/

MIDIClient.init;
MIDIIn.connectAll;

// print the message 'key down' on each new .noteOn
MIDIdef.noteOn(\noteOnTest, {'key down'.postln});

// MIDIdefs are destroyed by pressing ctrl+. / cmd+. (by default)
// to add some permanency set the permanent_ attribute
MIDIdef.noteOn(\noteOnTest, {'key down'.postln}).permanent_(true);

// remove permanency later, by setting the attr to false
MIDIdef(\noteOnTest).permanent_(false);

// to free a named MIDIdef
MIDIdef(\noteOnTest).free;

// to free all MIDIdefs at once
MIDIdef.freeAll;


/*
       1.1 Get SC to print MIDI note number, velocity, midichannel.

*/

// it's good to first inspect what kind of data you are getting when you hit the midi device key/pad
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn, chan, src].postln
});
)

/*
  for every single key I press I get two messages in sequence.
  [ 78, 50, 0, 1 ]
  [ 78, 50, 0, 2 ]

  Eli shows in the video that this is not the case for him, but he does have a similar issue
  lateron with pitchbend being sent 3 times for each event. (coming from different channels but the
  same source).

  We can filter, or we can connect to the device by index.

  MIDIClient.init;
  MIDIClient.sources;
  MIDIIn.connect(1);

  now if i hit 5 keys: 5 unique messages
  [ 25, 62, 0, 1 ]
  [ 36, 59, 0, 1 ]
  [ 21, 57, 0, 1 ]
  [ 16, 59, 0, 1 ]
  [ 21, 62, 0, 1 ]

*/

// we only need velocity and note.. for now
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
});
)

// let's trigger a Ugen from inside the MIDIdef to get our first sounds





