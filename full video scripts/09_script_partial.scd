Hey everyone, welcome to tutorial number 9. Here I'll show you the basics of getting SuperCollider to communicate with other MIDI devices.

Just a few words before we begin. If you're watching this video, then I'm assuming you've already got a general understanding of what MIDI is, so I'm not gonna go into a ton of depth here. But, if you don't know much about MIDI, then in short, MIDI, which stands for Musical Instrument Digital Interface, is a communication protocol for allowing musical devices, such as synthesizers, computers, etc, to talk to each other. (It's essentially a language for describing an arbitrary musical performance).

I suggest taking a look at the guide called "Using MIDI", which gives a very broad overview of the MIDI classes in the SuperCollider library. There's also a guide simply titled "MIDI", which gives an overview from a somewhat different perspective.

So how do we use MIDI in SuperCollider? Well, first things first, SuperCollider needs to connect with the MIDI functionality of your operating system, and this is done with

MIDIClient.init;

In doing so, SC touches base with your operating system and its knowledge of available MIDI devices, and comes back with a list of MIDI sources and destinations. Now, as you can see, I don't have any. So I'm going to plug in my audio MIDI interface...and run this line again.

MIDIClient.init;

and now you can see that my EMU 0404 interface is online. For this tutorial, I've got a Yamaha psr 620 keyboard over here, which is sending MIDI data to this interface.

The next step is to connect SuperCollider with an actual MIDI device. Now techincally, you can get a list of your available MIDI sources with

MIDIClient.sources;

which gives an array of devices sending MIDI data, and then use MIDIIn.connect(, ) and specify a specify a device by giving the array index, but generally it's a lot cleaner and simpler to just say

MIDIIn.connectAll;

which enables SuperCollider to talk to all active MIDI devices.

So what's next? Let's um, get some MIDI data into the SC language. For actually interfacing with MIDI data, you'll use one of two similar classes. There's

MIDIFunc

and

MIDIdef

These two classes have a slightly different syntax, but perform the same function. They both allow you to register an action to be taken when a certain MIDI message is received. It would actually be kind of pointless to demonstrate both of these classes, since they really are very similar, so for the purposes of this video, I'm going to use MIDIdef. Now I like MIDIdef, because there are several "def" type classes in SuperCollider, most prominently SynthDef, but also Tdef, Pdef, Pdefn, Ndef, and so forth, so there's a certain homogeneity of syntax with MIDIdef that I find very appealing. And if you want, you can read the help file.

If I'm playing a keyboard synthesizer, then I'm certainly going to be dealing with note-on and note-off messages. So I'll create a MIDIdef to respond to note-ons, like this. Just like SynthDef, MIDIdef expects a symbol, which serves as the name of the def, and a function to be evaluated when a note-on is received. In this case I'll just print the words "key down" every time a note-on message is received.

MIDIdef.noteOn(\noteOnTest, {"key down".postln});

So, at least here we can verify that MIDI data is flowing into the program with no problems. So how do we make sound with this data? As usual, when we want to make sound in SC, we make a SynthDef.

