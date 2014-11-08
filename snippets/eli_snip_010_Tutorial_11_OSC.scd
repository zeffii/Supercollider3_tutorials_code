/*

             SuperCollider Tutorial: 11. TouchOSC
             https://www.youtube.com/watch?v=ZVTbRNu2BI0

             > In contrast to the MIDI protocol, OSC is faster, more flexible
             > more time accurate, and doesn't include a hardware specification.
             > OSC messages are most commonly sent over a network ( UDP / TCP )

             > The syntax of a OSC message consists of a URL style adress followed by
             > some number of arguments (often numbers, but not always)
             > OSC messages are sent to a specific IP address on a specific Port

             This video discusses OSC through an app called TouchOSC and its editor
             (which allows for custom interfaces, drag n drop sliders, rotaries etc)

             My (not Eli's) main interest in OSC is the formatting of the message and
             how SuperCollider can send/receive messages. Where the messages come
             from is not so relevant, i'll concentrate of what the messages are.

             Help docs: External Control / OSC / guide "OSC Communication"
*/

// start with an OSCdef to respond to some device with a known path
// See OSCdef man pages
// by default SuperCollider listens for input on port 57120
NetAddr.langPort;  // verify

(
OSCdef.new(
	\toggle,               // named OSCdef, this is given by you
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln; // gives a swathe of information.
	},
	'/main/toggle1'        // or whatever OSC address you want to receive from.
))

// filtering the content of the message
(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		// if the msg is an array then element 0 will give the origin-url '/main/toggle1'
		// msg[1] will give the second element. etc.
		// :: for toggle messages the value will usually be 0 or 1
		// :: for sliders, it can be any range of numbers
		// :: for enumeration, it can either be a named enum member or an index into a known collection.
		// :: etc.
		[msg[1]].postln;
	},
	'/main/toggle1'        // or whatever OSC address you want to receive from.
))


