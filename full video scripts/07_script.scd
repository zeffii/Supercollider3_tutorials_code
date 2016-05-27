Hey everyone, welcome to tutorial number 7. In this video I'll talk about the architecture of the audio server and take a more detailed look at how it works. The audio examples so far in this series have been pretty simple, usually just a few UGens within a single Synth. But as your SuperCollider work grows and becomes more complex, it's more likely you'll want to have many Synths running simultaneously, possibly passing signals to one another, some generating audio and others processing audio. To handle projects like this, it's very important to have a clear understanding of the basic design of the server.

First things first, let's boot the server and bring up the server visualization, just like we did in tutorial number 4, and I'll also bring up the level meters as we did in tutorial number 5.

s.boot;
s.plotTree;
s.meter

There are three concepts I'll discuss in this tutorial. Nodes, Busses, and Order of execution. Node is an abstract class of objects representing modules on the audio server. We don't deal with Node directly, instead we use its two subclasses, Synth and Group. Busses are used to pass signals between Synths, in other words, you can send a signal to a bus, and then use that signal as an input to anther Synth by reading from that bus. And last, there's Order of execution, which has to do with the specific order of nodes on the server.

As you might imagine, these concepts are closely related to one another, which makes it difficult to talk about one without talking about the others. So in order to explain these three topics, I'll use a simple example of passing audio between two Synths, in this case, sending audio from a generative Synth to be processed by a reverb Synth.

The first thing we need to do is create two SynthDefs. I'll create a sine wave with a frequency that jumps randomly between the first four partials of a 300Hz fundamental. And I'll transform this sine wave into short blips using a combination of Dust and Decay2.

(
SynthDef.new(\blip, {
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(0, sig);
}).add;
)

I pointed out in tutorial number 3 that audio bus 0 corresponds to your lowest-numbered hardware output, in this case, my left speaker. But we don't want to send this output to the speakers, we want to send it to another synth. So what I'll do here is declare an argument for the bus index, so that I can specify the output bus when I create the Synth. And, in general, it's always a good idea to declare arguments for bus indices, so that you always have the option to re-route the output signal.

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);
}).add;
)

In order to receive a signal from another Synth, we can use a UGen called In. In reads a signal from an input bus, and also needs to know how many channels to read.

(
SynthDef.new(\reverb, {
	var sig;
	sig = In.ar();
}).add;
)

I'll declare an argument for the input bus. And again, I'll decide the specific bus assignment when I create the Synth, but whatever bus I end up using, It'll be the same as the output bus for the sound source.

(
SynthDef.new(\reverb, {
	arg in;
	var sig;
	sig = In.ar(in);
}).add;
)

In this case, the incoming signal is monophonic, so I'm specifying 1 channel.

(
SynthDef.new(\reverb, {
	arg in;
	var sig;
	sig = In.ar(in, 1);
}).add;
)

Next, I'll apply reverb using FreeVerb...and I'll duplicate the signal so that we hear something in both speakers.

(
SynthDef.new(\reverb, {
	arg in;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
}).add;
)

Last, we output the processed signal. For the sake of consistency, I'll specify another argument for the output bus. But since this is the sound we actually want to hear, I'll set the default value to be 0.

(
SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

Before we instantiate these Synths, let's talk about busses. When it boots, the audio server has a fixed number of audio busses. You can get this number by evaluating

s.options.numAudioBusChannels;

The default value, as we can see, is 128. SuperCollider reserves a number of these busses for hardware outputs and inputs. These values can be found by evaluating

s.options.numOutputBusChannels;
s.options.numInputBusChannels;

The default for each of these is 8 busses. This means, that by default, busses 0 through 7 are reserved for hardware output, 8 through 15 are reserved for inputs, and 16 through 127 are so-called private busses, in effect, "safe" choices for internally routing audio signals between Synths. Now, there's nothing stopping you from using hardware busses for internal routing, but it's not a good idea, because you can run into feedback if you're not careful.

There are situations where you might want to change the number of hardware inputs and outputs that SuperCollider reserves for you. Maybe you have an audio interface with 2 inputs and 4 outputs. You can change these values by setting the server attributes equal to new values, like this:

s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 2;

But the main thing to remember is that you need to reboot the server for these changes to take effect.

s.reboot;

This change will be reflected in the level meters, once you close and reopen the window.

s.meter;

So now, busses 0 through 3 correspond to your hardware outputs, while 4 and 5 correspond to your hardware inputs, and now, 6 through 127 are private busses, available to you however you want to use them.

So let's call up our reverb synth. For the duration of this video, I'm going to use the global variable y for the reverb Synth, and x for the sound source. I'll specify input bus 6, but of course we could use any integer from 6 up to 127.

y = Synth.new(\reverb, [\in, 6]);

We can the Synth appear on the server, but we don't hear anything yet because there's no signal being written to bus 6. So let's call up our sound source, and specify bus 6 as its output destination.

x = Synth.new(\blip, [\out, 6]);

Here's a quick demonstration of how bus routing works. Let's imagine a more complex setup in which I had a different effect synth reading signal from bus 25. I could re-route the sound source by changing the output bus, like this:

x.set(\out, 25);

The sound stops, because there's no longer any signal being sent to bus 6, which is what the reverb synth is listening to. And there's nothing processing signal from bus 25, so the sound source has reached a dead end. We could, however, re-route the reverb synth as well, like this,

y.set(\in, 25);

And the synthesis chain is intact once again.

Another nice consequence of dividing the synthesis chain into component nodes, instead of having one big Synth handling everything, is that we can dismantle the synthesis chain piece-by-piece. If we free the sound source but leave the reverb node alone,

x.free;

then the sound stops in a very natural-sounding manner. The source is removed, but the reverb effect remains for as long as it needs to completely decay the sound. And now we can free the reverb synth at leisure.

y.free;

On the other hand, if the sound source and reverb effect were part of the same synth, we'd be forced to free them together, and the entire sound would stop much more suddenly, like this:

y = Synth.new(\reverb, [\in, 6]);
x = Synth.new(\blip, [\out, 6]);

s.freeAll;

Let's talk about busses some more. Generally, it can be problematic to specify a bus with an integer, since, by doing this, we're hard-coding that value. For example, if you're using a new audio interface, it might not have the same number of inputs and outputs as you're used to, and so bus 6 might conflict with a hardware channel. In this case, you'd have to go back into your code and change numbers around, and that's kind of annoying.

For this reason, you should use the Bus object, in order to let SuperCollider handle the allocation of busses for you. We can grab a reference to a private audio bus by evaluating Bus.audio and by storing the result in a global variable, I'll call it reverbBus. This method needs to know what server the bus belongs to, in this case it's the local server stored in the variable s, and it also needs to know how many channels of audio it's dealing with. And as I mentioned, at this point we're just dealing with a monophonic signal.

~reverbBus = Bus.audio(s, 1);

According to the post window, this is an audio bus with index 6, it expects one channel of audio, and it belongs to the localhost server. When using the Bus object to allocate an audio bus, SuperCollider will always choose the lowest available bus that doesn't conflict with hardware outputs. Currently, we have 4 hardware outputs and 2 hardware inputs, so the server assumes busses 0 through 5 are unavailable, and 6 is the first available private bus. If we hadn't changed the default values, we'd still have 8 outputs and 8 inputs, and in that case, bus 16 would have been the first available private bus.

We can us the 'index' method on a bus to return its integer index

~reverbBus.index;

So we can now revisit the previous example, and replace the integer with the bus index, like this:

y = Synth.new(\reverb, [\in, ~reverbBus.index]);
x = Synth.new(\blip, [\out, ~reverbBus.index]);

x.free;
y.free;

Turns out you don't even need to use dot index. When SuperCollider receives a Bus as an argument value, it gets tranlated into the index of that bus, automatically.

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);

x.free;
y.free;

You won't always be dealing with 1-channel signals, so I'll change these SynthDefs in order to demonstrate how SuperCollider deals with bussing multichannel signals.

First I'll add a UGen called Pan2, which pans a monophonic signal across a stereo field, and I'll control the pan position with a noise generator. Multichannel UGens like Pan2 can be a little deceptive because there are no Arrays or exclamation points to suggest multichannel expansion, but that's just how these UGens work. If we send the output of this Synth straight to the hardware outputs by specifying bus 0, we can see that, sure enough, there are two channels:

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\blip, [\out, 0]);
x.free;

We need to change the reverb synth too. Since we're outputing a stereo signal, there's no longer any reason to multichannel expand the processed output. We also need to change the input UGen to read 2 channels instead of just 1.

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)

And last, we should also allocate a two channel bus, like this:

~reverbBus2 = Bus.audio(s, 2);

And take a look at the post window here. Because we've already allocated a one channel audio bus, SuperCollider remembers this, and assumes we're still going to use it for something, so bus 7 was the lowest available private bus.

This brings up a very important point, and it's that in SuperCollider there's no such thing as a multichannel bus. Instead, one bus corresponds to one channel of signal. The Bus help file puts it very clearly, pointing out that

"using the Bus class to allocate a multichannel bus does not 'create' a multichannel bus, but rather simply reserves a series of adjacent bus indices"

This means that the bus we've just allocated, ~reverbBus2, is not actually a stereo bus. Instead, SuperCollider has set aside two busses, with indices 7 and 8. And just to prove this, I'll allocate another 1-channel bus, and we can see in the post window, that the audio bus with index 9, not 8, is the next available private audio bus.

~reverbBus3 = Bus.audio(s, 1);

If we use dot index on our so-called 2-channel bus, SuperCollider returns the lowest numbered index in the series of adjacent busses -- in this case, 7.

~reverbBus2.index

But, as we saw in tutorial number 5, remember what happens when we output a multichannel signal to a single bus. SuperCollider will distribute the remaining audio channels on consecutive, ascending busses.

So, returning to our modified example, the first channel of the sound source is sent to bus 7, and the second channel to bus 8. The reverb synth reads the stereo signal split between these two busses, applies reverb, and sends the result to busses 0 and 1.

y = Synth.new(\reverb, [\in, ~reverbBus2]);
x = Synth.new(\blip, [\out, ~reverbBus2]);

x.free;
y.free;

But, Notice, that if we instead used our original 1-channel bus, everything still works exactly the same

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);

x.free;
y.free;

Even though this bus is supposedly a one-channel bus, SuperCollider doesn't know or care. All it does is determine the index associated with this bus allocation, which happens to be 6, which means the stereo sound source is now being written to busses 6 and 7, instead of 7 and 8. But hopefully, you can see how this might be problematic. For instance, we might be using busses 7 and 8 for something else, and with a stereo signal being written to bus 6, we risk having signal overlap on bus 7, and that can lead to other unintended consequences.

So the bottom line with busses is that there's nothing magical or sophisticated about using the Bus object to allocate audio busses, other than the fact that it avoids hardware busses. It's entirely the user's responsibility to make sure that the number of channels matches the number of busses, and that there are no conflicts or overlaps. And, in fact, the Bus help file warns the reader of exactly the same thing.

I'll move away from busses for now, and turn the discussion to order of execution, but I'll stick with the same example in order to demonstrate a common pitfall. Let's say, innocently enough, we create these two Synths in the reverse order.

x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2]);

Well, where's the sound? We've got both Synths on the server, and they're sharing the same audio bus. The silence we're hearing is a consequence of order of execution. There's a help document called order of execution, and it describes the issue in a very straightforward way:

"if you have a synth on the server (i.e. an "effect") that depends on the output from another synth (the "source"), the effect must appear later in the chain of nodes on the server than the source."

When you've got more than 1 Synth on the server, their outputs are not calculated simultaneously, but instead, they're calculated from top to bottom, or as it's more commonly called, head to tail. According to the current node order, the reverb synth is at the head of the node tree, which means, on every control cycle, its output is calculated first. But the sound source hasn't been calculated yet, so there's no input to the reverb synth. Next, the sound source is calculated and sent to busses 7 and 8. But the reverb synth that's listeting to these busses has already calculated its output, so we hear nothing.

s.freeAll;

Before we talk about how to place nodes in a specific order, we should have a more complete discussion about nodes themselves, in particular, we haven't talked about Groups yet. As I mentioned, Node has two subclasses, Synth and Group. We're already very familiar with Synths, so let's talk about Groups. A Group is essentially a collection of nodes in a specific order. The nodes inside of a Group can be both Synths and other Groups.

When we add a Synth node to the server, it appears as a white rectangle on the node tree;

x = Synth.new(\blip, [\out, 0]);

and when we add a Group node to the server, it appears as a gray rectangle, like this;

g = Group.new;

If you look closely at the node tree, you'll see that these two nodes we just created are actually contained within another group node. This larger gray rectangle represents the default group, which is created for you whenever you boot the server.

We already know that Synths can be removed by using the free method

x.free;

and, turns out, the same applies to groups

g.free;

With this very brief introduction to groups, I'm going to revisit the Synth help file, which I briefly touched on in tutorial number 3. As we saw in that video, the third and fourth arguments of Synth.new are target and addAction

A target is ultimately a Synth or a Group, but we also have the option to specify a server, or nil, meaning we don't specify anything for a target. If we specify a server as a target, SuperCollider translates this into the default group on that server. And if we specify nil, this is translated to the default group of the default server. We also have the option to specify an integer as a target, which corresponds to a node ID, but we haven't talked about node IDs, and it's probably too much of a distraction right now. The other argument, addAction, specifies where to place the node relative to the target.

So let's get back to our reverb example and put these two arguments to work. When we created these two Synths one after the other,

x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2]);

they ended up in the wrong order. This is because the default value for addAction is addToHead. So in this case,

x = Synth.new(\blip, [\out, ~reverbBus2]);

the blip synth is added to the head of the default group,

y = Synth.new(\reverb, [\in, ~reverbBus2]);

and then the reverb synth is added to the head of the default group, therefore ending up BEFORE the sound source.

s.freeAll;

There are many ways to do this correctly, since the only requirement is that the reverb synth ends up after the sound source. One possible approach is to specify addToTail on the reverb synth. And we might as well add targets to these Synths while we're at it, just to be extra diligent.

I'm specifying the local server as a target, which means these Synths will end up in the default group of the local server. And now the order in which we create these nodes doesn't matter, because the effect Synth will always be added to the very end of the default group.

x = Synth.new(\blip, [\out, ~reverbBus2], s);
y = Synth.new(\reverb, [\in, ~reverbBus2], s, \addToTail);

y = Synth.new(\reverb, [\in, ~reverbBus2], s, \addToTail);
x = Synth.new(\blip, [\out, ~reverbBus2], s);

Here's another way to place these nodes in the correct order. Let's create the sound source first

x = Synth.new(\blip, [\out, ~reverbBus2]);

And we'll specify this synth, called x, as a target for the effect Synth, and we'll use \addAfter as our addAction

y = Synth.new(\reverb, [\in, ~reverbBus2], x, \addAfter);

Which places the reverb synth immediately after the sound source in the node chain. I'll free the sound source for a second,

x.free;

in order to demonstrate one of several alternatives to Synth.new. In the help file, there are several convenience methods, one corresponding to each addAction.

So, since our reverb synth still exists, we can re-instantiate the sound source using Synth.before

x = Synth.before(y, \blip, [\out, ~reverbBus2]);

x.free;
y.free;

You can use Groups to your advantage, too. Since a sound source should always appear before an effect, you can create a Group for your sources and a group for your effects. The five convenience methods in the Synth help file are also available for Groups, so I'll use group.after for the effects group.

~sourceGrp = Group.new;
~fxGrp = Group.after(~sourceGrp);

As long as these groups are in the proper order, you don't have to worry about the order of your synth nodes, as long as they get added to the correct groups.

x = Synth.new(\blip, [\out, ~reverbBus2], ~sourceGrp);
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGrp);

x.free;

I'm going to add a few arguments to the blip SynthDef to demonstrate another important advantage of using Groups.

(
SynthDef.new(\blip, {
	arg out, fund=300, dens=2, decay=0.2;
 var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;
)

Now, using iteration, I'll create 8 instances of this SynthDef, making sure to add them to the correct Group

8.do{Synth.new(\blip, [\out, ~reverbBus2, \fund, exprand(60,300).round(30)], ~sourceGrp)}

I haven't given these Synths any names, but it doesn't matter because they're contained within a Group that I can refer to by name. We know that we can use the set message to change a control argument of a single Synth. But we can alternatively send a set message to a Group, which causes the group to relay that message to all the nodes within it.

~sourceGrp.set(\decay, 0.05);
~sourceGrp.set(\dens, 12);
~sourceGrp.set(\dens, 0.25);
~sourceGrp.set(\decay, 1);

It's a very convenient way of sending messages to many nodes at once. And instead of having to free these Synths with eight individual statements, we can just tell the group to free all of the nodes that it contains, like this

~sourceGrp.freeAll;

That's all for tutorial number 7. As always, one of the best ways to understand these concepts is to experiment, by practicing adding and removing nodes from the server. I encourage you to read the help files for Synth, Group, and Node more closely, and maybe take a look at the documents on Order of execution and Server Architecture to get a better idea of what's going on. I hope this video helps clarify the design of the audio server and points you in the right direction. Please leave any comments or questions on YouTube, and thanks for watching.