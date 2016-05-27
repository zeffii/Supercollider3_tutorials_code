Hey everybody, welcome to tutorial 17. In this video we're gonna use what we developed in the previous two tutorials and put together an environment in which we can perform and modify a simple musical composition. For your convenience, I've included a link in the video description below where you can download the code we'll develop in this video, to save you the trouble of having to type it all out yourself, although I do encourage you to follow along with the video to better understand each step.

One of our main concerns in building this performance environment will be to avoid scattered chunks of code that need to be evaluated individually, and instead group all the components together so that the entire setup process can be invoked with a single keystroke. With this type of approach, as you can probably guess, the order in which we do things is going to be very important, because there are certain things that need to happen before other things. For example, we can't read a soundfile into a buffer unless we've booted the server first, and we can't create a Synth unless we've first added the corresponding SynthDef, and so on.

Let's begin with an overview of what the structure of this code might look like.

What I like to do, is first configure the audio server, initialize any simple global variables, then define several piece-specific functions, which handle things like reading soundfiles into buffers, allocating audio busses, etc. And after that I register these functions with ServerBoot, ServerQuit, and ServerTree classes, which controls precisely when these functions get evaluated. Then, we boot the server, and once the server is booted, evaluate any remaining code that requires a booted server and hasn't already been handled by steps 1 through 4.

//1. server config
//2. initialize global variables
//3. define piece-specific functions
//4. register functions with ServerBoot/Quit/Tree
//5. boot server
//6. anything else requiring a booted server

So, let's get into the details. On the desktop, I've got the project folder from tutorial 16. Inside this folder, the code we developed in the last two videos, which includes our three SynthDefs, two Pbinds from tutorial 15, a line of code that allocates an audio bus for our reverb synth, and the code for reading multiple folders of sound files into a dictionary of buffers. The folder of sound files is mostly the same, the only difference is that I've added a few more sound files to the shakers folder. So what I'm going to do is start with this very basic unstructured code, and sort of build around it so that it eventually resembles this structural overview, which I'll copy and paste into our basic code.

The first step is configuring the audio server. Even though the local server is automatically stored in the global variable s when we start SuperCollider, it's not a bad idea to do it yourself just to make sure. And then, we want to configure the server using the ServerOptions class, and we saw a little bit of this in tutorial 7. Here we're talking about things like setting the sample rate, the audio hardware device, number of hardware output busses, just basically anything that requires a server reboot in order to take effect. We'll start by setting the output device, with s.options.outDevice. We can see the available devices with ServerOptions.devices. And what you can do after evaluating this line is just copy and paste the desired device from the post window into your code, making sure to enclose the device name in quotation marks. So with this choice, I'd be using my computer's built-in audio output. But maybe in some cases, I might want to use my MOTU interface, and in fact, because I'm making a tutorial video, I actually want to use Soundflower to route audio from SuperCollider to my recording software. So if you envision yourself using different devices in different situations, what you can do is copy all of them onto multiple lines, like this, and then just comment out the ones you're not gonna use. If we boot the server... we can see that SuperCollider is using Soundflower as its output device '/*don't clear post*/.

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);

Next let's set the number of hardware output busses. Since we're using Soundflower, we should specify two output busses, because Soundflower has two available outputs... it actually says 2 channels in the device name itself. So we type s.options.numOutputBusChannels and set that value equal to 2. Now, if I were using the MOTU instead, I'll just temporarily uncomment it, evaluate, quit and reboot the server...

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	"MOTU UltraLite mk3 Hybrid"
	//"Soundflower (2ch)"
);
s.options.numOutputBusChannels_(2);


and now we can see that the MOTU is the output device. We can also see that the MOTU has more than two output channels-- in fact it has fourteen. I'm familiar enough with this MOTU to know that these two channels correspond to its two main analog outputs, then we have another 8 analog outputs, two digital SPDIF outputs, and a stereo headphone output. In a performance, we almost certainly wouldn't be using all of these outputs simultaneously, but it's a good idea to set numOutputBusChannels equal to the total number of device outputs so that the localhost server is consistent with the hardware, and this way all fourteen outputs are all available regardless of which outputs we actually end up using. If we evaluate, quit and reboot the server,

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	"MOTU UltraLite mk3 Hybrid"
	//"Soundflower (2ch)"
);
s.options.numOutputBusChannels_(14);

and then open the level meters, we see a total of 14 hardware output channels. And this means, if I choose, I could send sound to the first analog output, corresponding with output bus 0,

{Out.ar(0, PinkNoise.ar(0.2))}.play;

or the first digital output, which corresponds with output bus 10

{Out.ar(10, PinkNoise.ar(0.2))}.play;

Essentially, you want to make sure you know how many outputs your device has, and make sure you give the localhost server that many output bus channels. So now let's go back our 2-channel soundflower setup. [close and reopen meters?]

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);
s.options.numOutputBusChannels_(2);

If your piece involves microphones or some other audio input, you'd want to add s.options.inDevice_("my device") and choose the correct name for the hardware device you're using, which may or may not be the same as the hardware output device, and also set the correct number of input bus channels, just like we did with the output busses. The composition we'll create in this video won't have any live audio input, so this code doesn't really matter in this case, but for posterity, I'll leave it here and make it look sort of reasonable.

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(2);
s.options.numInputBusChannels_(2);

In the Mac OS Audio MIDI Setup Utility, we can examine Soundflower 2 channel, which we're using as our output device, and we can see that it's currently set to a sample rate of 44100, and we want SuperCollider to be running at that rate too, we can do with s.options.sampleRate.

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(2);
s.options.numInputBusChannels_(2);
s.options.sampleRate_(44100);

And one last thing I like to do is set the amount of real-time memory that the server is allowed to access. s.options.memSize tells us that the default is 8192 kilobytes

s.options.memSize;

One of the more common situations where real-time memory comes into play is when using delay lines that allocate memory on the fly, instead of relying on explicitly allocated buffers, this includes UGens like DelayN, and CombN. So, for example, using the default memSize, let's create a UGen function that delays PinkNoise by one second.

{DelayN.ar(PinkNoise.ar(0.2), 1, 1)}.play;

No problem. even ten copies of this function is doable with the current memSize

10.do{{DelayN.ar(PinkNoise.ar(0.1), 1, 1)}.play;}

But, if we try something to the tune of 50 1-second delays...

50.do{{DelayN.ar(PinkNoise.ar(0.02), 1, 1)}.play;}

The server slams us with memory allocation messages. If you ever see this behavior in the post window, it means you're asking the server to allocate more real-time memory than the amount of memory it'l allowed to allocate. Now, I might not be 100% accurate with the details of the math, but here's the basic concept. With a 1-second delay, we need enough memory to store 44100 samples. So a good question is, how many kilobytes is 44100 samples? Well, by default, SuperCollider outputs audio in 32-bit float format by default. And there's 8 bits in one byte. So if 32 bits are being used for one sample, then one sample is equal to 4 bytes, 32 divided by 8. So one second of audio is 176400 bytes. Divide by 1000 and we've got 176.4 kilobytes. So our first example with a single one-second delay, needs approximately this many kilobytes of real-time memory. This is totally fine with a default memSize of 8192 kilobytes. With ten delay lines, we're still fine, but a 50 second delay, that's greater than 8192 and that's when we start to run into problems.

s.options.memSize

44100 * 4
44100 * 4 / 1000
44100 * 4 / 1000 * 10
44100 * 4 / 1000 * 50

So the solution here is to set a higher memSize before booting the server. I've gotten in the habit of specifying a value of 2 to the power of 20, and I don't think this value even needs to be a power of 2, but anyway this is roughly a gigabyte of real-time memory, and it's probably extremely generous, even if you're using a lot of delay lines. In most cases, you probably won't be using anywhere near this volume of memory. But, for what it's worth, I've never run into any problems using this value, and it's just one of many SuperCollider habits I've gotten into over the years.

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(2);
s.options.numInputBusChannels_(2);
s.options.sampleRate_(44100);
s.options.memSize_(2.pow(20));

//ServerBoot.removeAll etc later

You can read the ServerOptions help file to see other server configurations that are possible, but I'm going to call this section done and move on to the next section of initializing global variables.

//2. initialize global variables

This section is pretty open ended, and this is where I'll stash declarations of values that I want to be able to access anywhere else in the code. So this might be things like an integer corresponding to some initial index into a collelction, arrays containing pitch values or amplitude values, just, really anything that makes sense to keep track of in the context of your composition.  Right now, there's only one global value in particular that I would like to include, and that's an integer index corresponding to the lowest numbered hardware output bus that we'd like to use.

~out = 0;

In many cases, and in many of the previous tutorials, zero has been our lowest-numbered hardware output bus, and we've been hard-coding this value in, for example, un a UGen function that looks like this,

{Out.ar(0, PinkNoise.ar(0.2!2))}.play;

or a Synth.new statement that looks like this:

Synth.new(\sound, [\out, 0]);

And what's happened to me a few times is that I'll find myself at some electroacoustic concert or festival where I transfer my SuperCollider code to a different computer, but then this new computer is sending audio to hardware outputs that don't correspond with index zero. Like, for example, we saw a bit earlier that my MOTU interface has ten analog outputs with indices 0 through 9, and then above that, two digital outputs at indices 10 and 11. And if you findy yourself in this situation, you might have to comb through your entire code and replace all these zeros with some other number. And unfortunately you can't just do a massive find-and-replace operation, because the zero character usually appears, like, everywhere, so this becomes a really stupid and tedious chore. So by creating a global variable for the lowest output bus index, you can then use that variable in the rest of your performance code, like this. And so then if you end up in a situation where, oh, for whatever reason, we're using the digital outputs, and those begin at index 10, you only have to change this one line of code at the top of your file, and then this change automatically propagates throughout the rest of your code, which is very convenient.

~out = 10;

{Out.ar(~out, PinkNoise.ar(0.2!2))}.play;

Synth.new(\sound, [\out, ~out]);

~out = 0;

If later on we find the need for more global variables, we'll revisit this section, but for now this is all I want to add, so we'll move on to the next section, in which we're gonna define several language-side functions, each of which contains some code designed to handle one specific aspect of the composition. So for example, we're gonna want a function that reads soundfiles into buffers, a function for allocating busses on the server so that we can route signal through our reverb synth, a function for creating an initial tree of groups and synths on the server, another one for handling cleanup whenever we quit the server, that sort of thing. Let's start with a function for reading soundfiles into buffers, since we already have that code from the last video. So let's cut... and paste this code up here, and all we're going to do is enclose it in curly braces to create a function, and give it a global variable name, ~makeBuffers.

//3. define piece-specific functions

~makeBuffers = {
	b = Dictionary.new;
	PathName("/Users/eli/Desktop/Tutorial Piece/buffers/").entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};

Notice that when we now evaluate this clump, we're only defining the function, and not actually evaluating its contents, we can verify this by evaluating b, which is still nil, and not a dictionary yet.

b;

In section 4 of our performance environment, we're going to use ServerBoot, ServerTree, and ServerQuit to schedule the evaluation of this function and other ones like it. So let's actually start doing that right now. Functions registered with ServerBoot will be evaluated immediately after the server boots, functions registered with ServerQuit will be evaluated automatically when the server quits, and functions registered with ServerTree will be evaluated whenever the node tree is re-initialized, which is triggered by things like evaluating s.freeAll or hitting command-period. So the first question we want to ask ourselves is-- when do we want buffers to be allocated? Well, we don't want this to happen after the server quits, because, that doesn't make any sense. And there's no need to do this every time the node tree is reset, because command period doesn't have any affect on allocated buffers. So ServerBoot is probably the best choice. To register this function, we simply type ServerBoot.add, and then provide the name of our function.

ServerBoot.add(~makeBuffers); //eval

In the last video I mentioned that code inside this function is pretty robust-- you can go into your sound file library and add or remove sound files or subfolders and this code'll still work. In fact let's just take a moment to make sure it works now. So, boot the server, and this function should be automatically evaluated for us.

s.boot;

And, sure enough, b is a dictionary, and so we should be able to play any of the soundfiles stored within.

b;
b[\deskBells][8].play;

Good, so let's free all Buffers...and quit the server,

Buffer.freeAll;
s.quit;

and now let's imagine a situation where you take this main project folder and, for example move it to somebody else's computer, or another example, let's actually move this folder to a new location on my computer-- so first we save this scd file. Then I'm going go into Applications, and the SuperCollider folder...and move the project folder it here. Then close this scd file and open the scd file in this new location...And now, well, this pathname is inaccurate-- this is no longer the location where our sound files are stored. So if we do the same process as before, b is an empty dictionary, our sound files haven't been properly loaded, and if we try to play one of them, we get an error message.

s.boot;
~makeBuffers.value;
b;
b[\deskBells][8].play;

Here's one way you can avoid this problem. In the SuperCollider language, most of the time, if you type a word starting with a lowercase letter, SuperCollider decides it's a local variable that needs to be declared before it can be used. Like, if I just type some word starting with a lowercase letter, SuperCollider complains, like we'd expect it to.

random;
words;

But, there's a handful of special cases in which we can use a lowercase word that doesn't require declaration. Two somewhat common examples are the booleans

true;
false;

And one less-common example is called thisProcess, lowercase t, uppercase P.

thisProcess

thisProcess is an instance of a class called Main which... you know what? we're not gonna worry about this too much because we're getting dangerously close to the nuclear core of SuperCollider. Main is one of those classes that is probably really critical to the deep essential functionality of SuperCollider, but it doesn't really have anything to do with musical functionality. Probably the best I can do is say that basically, thisProcess provides a way for the SuperCollider environment to refer to itself. And there's a method for thisProcess called nowExecutingPath

thisProcess.nowExecutingPath;

Which returns a string representing the path to the code file you are currently editing, assuming you've saved that file at least once. So, using this current scd file, thisProcess dot nowExecutingPath returns a path through Applications/SuperCollider, etc, where I just moved this folder.

So, hopefully, you can see where I'm going with this. We are gonna modify the pathname at the top of our makeBuffers code, incorporating thisProcess.nowExecutingPath so that it always works no matter where we put the main project folder. But first I'm going to save and close this scd file and move this folder back to the desktop, because that's where I want it to be and I don't want things to get more confusing than they need to be. So here's our original version, from the desktop.

Ok so thisProcess.nowExecutingPath gives the path to this current code file, but we want the path to the folder called buffers, which is in the same parent folder.

thisProcess.nowExecutingPath;

First, let's create an instance of PathName from thisProcess.nowExecutingPath, and then ask for the parent path.

PathName(thisProcess.nowExecutingPath).parentPath;

This gives us a string representing the path to the parent folder, so now we can just use the plus plus concatenation operator to append the string "buffers/".

PathName(thisProcess.nowExecutingPath).parentPath++"buffers/"

And what we'll do is create another global variable in section 2 called ~path, and set it equal to this line of code, and then replace our hard-coded path with this new variable.

~path = PathName(thisProcess.nowExecutingPath).parentPath++"buffers/";

~makeBuffers = {
	b = Dictionary.new;
	PathName(~path).entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};



Re-define our new makeBuffers function, register it with ServerBoot, and then reboot the server.

ServerBoot.add(~makeBuffers);
s.boot;

b[\crotales][0].play;

And our dictionary is once again properly filled with buffers, and you can take my word for it, or try it out yourself, that this code, using a dynamically generated pathname, will properly load your sound files, no matter where your project folder happens to be.

Ok, so, next function. Since we've got a reverb SynthDef, that means we'll be passing audio between Synths, and that means we should allocate an audio bus. So, we'll make a function called makeBusses to handle this task.

And instead of just copying our existing Bus.audio code into this function as is, what I'm actually gonna do here is create another Dictionary, call it ~bus, add to the dictionary a stereo audio bus, stored at the symbol reverb. And if we need more busses for any reason, we can just add another line below, like this.

//BUSSES
~makeBusses = {
	~bus = Dictionary.new;
	~bus.add(\reverb -> Bus.audio(s, 2));
};

We now want to register this function, so should we choose ServerBoot or ServerTree? And here, registering with ServerTree would actually be a mistake, I think, because if we did, that means every time we hit command period or reinitialize the node tree, SuperCollider will re-evaluate this function and would therefore allocate another stereo bus. Watch what happens if we manually re-evaluate these two lines several times in a row.

~bus = Dictionary.new;
~bus.add(\reverb -> Bus.audio(s, 2));

The size of the dictionary doesn't increase, BUT SuperCollider remembers the index of the last allocated bus and moves up to the next available index when we ask for another. And there's a limit here, determined by s.options.numAudioBusChannels, and if we hit that limit, we'll get an error message.

s.options.numAudioBusChannels;

So I'm gonna register this function with ServerBoot.

ServerBoot.add(~makeBusses);

And this is probably a good a time as any to create some sort of cleanup function, which gets evaluated when we quit the server to basically just tie up any loose ends. For example, we'd probably want this cleanup function to de-allocate any busses, so we'll make a function called ~cleanup, and inside, to reset the server's bus index counter, we use

~cleanup = {
	s.newBusAllocators;
};

And we could also use this function to un-register all the functions that we registered with ServerBoot, ServerTree, and ServerQuit, using the removeAll message.

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

And, register this cleanup function with ServerQuit. ServerQuit, like so

ServerQuit.add(~cleanup);

And, you know, it's probably a good idea to include this cleanup code with our server configurations in section 1, just to be extra safe.

//1. server config
s = Server.local;
s.options.outDevice_(
	//"Built-in Output"
	//"MOTU UltraLite mk3 Hybrid"
	"Soundflower (2ch)"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(2);
s.options.numInputBusChannels_(2);
s.options.sampleRate_(44100);
s.options.memSize_(2**20);
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

Ok, next function. As we saw toward the end of the previous video, we don't want to have to manually re-instantiate a reverb synth, or any other effect Synths for that matter, every time we hit command period, because, that's annoying and tedious. But any function registered with ServerTree is automatically evaluated whenever we hit command period or otherwise free all the nodes from the server, so ServerTree is really a perfect fix for this problem. So let's make a function called ~makeNodes, and register it with ServerTree, and this function will be responsible for creating an initial desired configuration of groups and synths on server.

So we'll make two groups, one will be the so-called main group at the head of the node tree which will be the target for any synths that just generate signal, and the other group will be specifically for our reverb synth, making sure that the reverb group is placed after the main group. And then, we want an instance of the reverb synth to be created for us, I'll put some specific argument values here in case we want to change them later, and here's a moment where we can use some of the code we've created earlier in this video, specifically, the reverb synth will read signal from the reverb bus we've allocated in our bus dictionary, and the reverb synth will output to the bus index specified by our global variable out. And of course we want to make sure that this reverb synth's target is our newly created reverb group.

The last thing I'm going to do with this function, which I guess is sort of a finesse and probably not absolutely necessary, is wrap the contents of this function in s.bind. s.bind takes a function containing server commands and groups them together as one bundle of OSC messages, making sure they get executed by the server at exactly the same time. This is basically just to guarantee that we don't accidentally try to add the reverb synth before creating the reverb group, because in that case we'd get a node not found message. And like I said, I'm probably being fancier than is actually necessary-- if you take away s.bind, it'll probably still work.

~makeNodes = {
	s.bind({
		~mainGrp = Group.new;
		~reverbGrp = Group.after(~mainGrp);
		~reverbSynth = Synth.new(
			\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				\revtime, 1.8,
				\lpf, 4500,
				\mix, 0.35,
				\in, ~bus[\reverb],
				\out, ~out
			],
			~reverbGrp
		);
	});
};

Now, I'm going to delay registering this makeNodes function with ServerTree, because, we haven't yet dealt with adding our SynthDefs, and of course that needs to happen before we can make any Synths. We'll get there.

So, one last function to define, and this one will be responsible for creating the actual musical events that constitute a performance of the piece. And rather than slog our way through what will probably be a fairly substantial function, I just want to code a very basic skeleton placeholder sort of thing and come back to it later in the video. In this function, we're gonna make a new dictionary, and give it a nice short name, just the global variable e, short for events, and we're going to add to this dictionary some number of musical event functions. So, e at event1 will point to to some function, e at event2 will point to another function, and so on. These functions will eventually contain things like Synth.new, Pbind.play, and other bits of code that generate or manipulate sound, but for now when we evaluate one of these functions we're just going to print the name of the event in the post window.

e[\event1].value;
e[\event2].value;

It's often desirable to use some sort of physical controller to trigger these musical events, and this makeEvents function is a perfectly reasonable place to connect available MIDI devices, and we'll also add a MIDIdef that responds to continuous controller messages. Again, having it do nothing for the time being and we'll come back to it later.

//EVENTS & MIDI
~makeEvents = {
	MIDIClient.init;
	MIDIIn.connectAll;
	e = Dictionary.new;
	e.add(\event1 -> {"event1".postln;});
	e.add(\event2 -> {"event2".postln;});

	MIDIdef.cc(\controller, {
		nil;
	});
};

I'll register this function with ServerTree, but like we did with makeNodes, I'm going to delay registering this function as well, mostly to help make sure that this makeEvents function doesn't inadvertently get evaluated twice.

And, with that, sections three and four of our performance environment are basically done, ignoring the fact that we don't actually have any musical events yet.

But let's move on to section five, where we finally, actually boot the audio server. But we can't just do s.boot; and immediately continue with things like SynthDefs, and whatever. What we need to do is tell the server to boot, which usually takes a second or two, and then wait until booting is complete before continuing. And we can do that using s dot waitForBoot. We provide a function, and waitForBoot boots the server, and when booting is complete, then and only then, the function we've given it.

s.waitForBoot({

});

Once the server is booted, this will trigger the functions ~makeBusses and ~makeBuffers because they've been registered with ServerBoot. And this will also trigger the ~makeEvents function, because booting the server causes the node tree to be initialized. And not all of these functions require the server to do something, but makeBuffers definitely does, reading sound files into buffers is a server-side job, and depending on how many sound files you have, this is going to take a little bit of time. So it's probably a good idea to start this waitForBoot function with s.sync. s.sync says to the server, 'hey whatever you're doing, finish it up, but let me know when you're done.' And when the server is finished doing whatever it's been doing, reading sound files into buffers or whatever, it says to the language ok I'm done, and that's the interpreter cue to continue with whatever comes after s.sync. So here, after s.sync is where I like to add my SynthDefs. So let's just cut and paste them in here.

s.waitForBoot({

	s.sync;

	SynthDef(\bpfsaw, {
		arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
		freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
		cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
		lsf=200, ldb=0, amp=1, out=0;
		var sig, env;
		env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
		sig = Saw.ar(freq * {LFNoise1.kr(0.5,detune).midiratio}!2);
		sig = BPF.ar(
			sig,
			{LFNoise1.kr(
				LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)
			).exprange(cfmin,cfmax)}!2,
			{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
		);
		sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
		sig = Balance2.ar(sig[0], sig[1], pan);
		sig = sig * env * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\bpfbuf, {
		arg atk=0, sus=0, rel=3, c1=1, c2=(-1),
		buf=0, rate=1, spos=0, freq=440, rq=1, bpfmix=0,
		pan=0, amp=1, out=0;
		var sig, env;
		env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
		sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf),startPos:spos);
		sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
		sig = sig * env;
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig);
	}).add;

	SynthDef(\reverb, {
		arg in, predelay=0.08, revtime=1.8,
		lpf=4500, mix=0.15, amp=1, out=0;
		var dry, wet, temp, sig;
		dry = In.ar(in,2);
		temp = In.ar(in,2);
		wet = 0;
		temp = DelayN.ar(temp, 0,2, predelay);
		16.do{
			temp = AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2, revtime);
			temp = LPF.ar(temp, lpf);
			wet = wet + temp;
		};
		sig = XFade2.ar(dry, wet, mix*2-1, amp);
		Out.ar(out, sig);
	}).add;
});

And here I want to do a sidebar about s.sync, because at first glance it probably looks pretty straightforward and convenient. And it is, but actually there are a few rules and concepts behind s.sync that I want to make clear, so here's an example that shows a case where s.sync is useful, how to implement it properly, and how to get avoid some error messages that might pop up.

s.quit; //clear post

As part of the design of SuperCollider being split into language-side and server-side, there's a distinction made between two types of execution, called synchronous and asynchronous-- There's a Guide file called Synchronous and Asynchronous Execution, which offers some good insight into this issue. Some server actions are synchronous, one of the simplest examples is reading samples that have been stored in a Buffer, using PlayBuf, for example. Synchronous actions are usually locked to the sample rate, and are given top priority, because if these types of things don't get top priority, then we risk sample dropouts that create clicks and pops and glitches and just garbage audio. And then there are asynchronous commands, which aren't locked to the sample rate, including things like SynthDef.add, Buffer.read. Asynchronous commands require some amount of time to finish, and this amount of time can vary depending on what else the server is currently doing, so we don't actually know exactly how long an asynchronous command will take. But, the reality is that we need certain things, usually asynchronous commands, to completely finish before certain synchronous commands can be executed-- For example, a SynthDef need to be added and fully loaded into memory before we can instantiate a corresponding Synth. Similarly, we usually want to to finish storing a sound file in a buffer before we play that buffer with UGens. So, in the following example, I'm creating and adding a SynthDef that takes 50 sine waves with random frequencies, sums them together, and applies a simple amplitude envelope. And what we'd like to do here is run one large chunk of code that adds the SynthDef and immediately creates a new Synth from that SynthDef. If we then evaluate these two commands together with one keystroke...

s.boot;

(
SynthDef(
	\synctest51,
	{
		var sig;
		sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
		sig = sig.sum;
		sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
		Out.ar(0, sig!2);
	}
).add;

Synth(\synctest51);
)


It doesn't work. As you can see, we get a SynthDef not found message. This is because the language tells the server-- hey add this SynthDef and then, almost instantaneously, the language says to the server -- hey make a Synth. But the server says hey that SynthDef doesn't exist because the server had not finished that particular asynchronous command.

But it's not like the server abandoned the SynthDef command, it just needed, maybe, a few more milliseconds to finish it. So, notice that now if we evaluate only the Synth command, it does actually work.

What we need to do, basically, is just wait a little bit after adding the SynthDef before playing the Synth. So, let's incorporate a one second wait time using 1.wait. Also, to make this demonstration work correctly, we need to add a SynthDef that doesn't already exist on the server, so to make sure that happens, I'm going to keep changing the name of the SynthDef before each evaluation.

(
SynthDef(
	\synctest53,
	{
		var sig;
		sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
		sig = sig.sum;
		sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
		Out.ar(0, sig!2);
	}
).add;

1.wait;

Synth(\synctest53);
)

This doesn't work either, and we get this wacky error message that says yield was called outside of a Routine. And this is probably one of the more confusing error messages for new users, because neither Routine nor yield appears in our code-- so what's really the problem here?

Well, it's probably worth talking about Routines. Basically, a Routine is a function that can pause in the middle of execution, and wait for something to happen before continuing- such as another task being completed or a certain amount of time elapsing. Here's a really simple example. Let's say we want to post "foo", wait 2 seconds, then post "bar".

(
"foo".postln;
2.wait;
"bar".postln;
)

This, is not allowed, and we get the same error. If we evaluate multiple code statements, we're not allowed to pause in between unless we're inside a pauseable process, and Routine is one such process. So, fixing this problem is as simple as enclosing our code in a Routine and playing it. And watch the post window here.

(
Routine({
	"foo".postln;
	2.wait;
	"bar".postln;
}).play;
)

So that works, and notice that this approach also works when server-side commands are included inside the routine.

(
Routine({
	{SinOsc.ar(440!2) * Line.kr(0.5,0,1,doneAction:2)}.play;
	2.wait;
	{SinOsc.ar(660!2) * Line.kr(0.5,0,1,doneAction:2)}.play;
}).play;
)

Another snag you might encounter occurs when you're creating or manipulating GUI objects inside a Routine. Watch what happens if we also try to create a Window inside the Routine.

(
Routine({
	~win = Window.new.front;
	{SinOsc.ar(440,0,XLine.kr(0.5,0.01,1,doneAction:2))}.play;
	2.wait;
	{SinOsc.ar(660,0,XLine.kr(0.5,0.01,1,doneAction:2))}.play;
}).play;
)

We get a different error message. SuperCollider says we're not allowed to use this functionality, and that we should try scheduling on AppClock instead. In SuperCollider there are three types of clocks: AppClock, TempoClock, and SystemClock. SystemClock is a high-priority clock, usually used for scheduling things that require great precision with respect to time. TempoClock is similarly accurate, in fact I think it might be equally accurate compared to SystemClock, but by design it's more musical than SystemClock, and thinks about time in terms of tempo, beats, bars, etc, instead of seconds. AppClock is a low-priority clock, and it's a good choice for scheduling things that don't need to happen at a precise moment in time. And, in fact, AppClock is the only clock that can schedule code that interacts with GUI, whether that code creates a GUI object, or gets or sets the value of a GUI. By default, Routines play using TempoClock, but we can change this by simply providing the name of a different Clock as the first argument to the play method at the end of a Routine.

(
Routine({
	//also works with server processes
	~win = Window.new.front;
	{SinOsc.ar(440,0,XLine.kr(0.5,0.01,1,doneAction:2))}.play;
	2.wait;
	{SinOsc.ar(660,0,XLine.kr(0.5,0.01,1,doneAction:2))}.play;
}).play(AppClock);
)

Even if we're not including GUI code, it's not necessarily a bad idea to play the Routine on AppClock anyway, and I've actually gotten in the habit of doing this. This is especially true for code that's meant to set everything up before a performance, where time accuracy isn't really an issue, you just want everything to happen in a particular order.

So with that problem out of the way. Let's get back to our SynthDef and Synth example, and insert a 1 second wait time between the SynthDef and the Synth.

(
//does work
Routine({
	SynthDef(
		\synctest53,
		{
			var sig;
			sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
			sig = sig.sum;
			sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
			Out.ar(0, sig!2);
		}
	).add;

	1.wait;

	Synth(\synctest53);
}).play(AppClock);
)

So this works, we hear sound about 1 second after evaluating the code. But, this is definitely kind of a sketchy solution, because, well, the thing about asynchronous commands like this SynthDef is that we don't really know exactly how long it's going to take. And in a lot of cases, we might have multiple SynthDefs, and the server might be doing other stuff at the moment. So, from a practical point of view, what we'd like to do is wait just long enough for our asynchronous commands to finish, but no longer than that, because, you know, we've got stuff to do, let's get on with it. And this is where s.sync comes in. Instead of specifying a fixed wait time, s.sync waits only until the server completes all pending asynchronous commands. So, once again let's evaluate, and you should be able to hear that the time between evaluating and hearing sound is only as large as it needs to be, definitely less than a second.

(
//with GUI, Routine must be played on the AppClock (low priority)
Routine({
	SynthDef(
		\synctest55,
		{
			var sig;
			sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
			sig = sig.sum;
			sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
			Out.ar(0, sig!2);
		}
	).add;

	s.sync;

	Synth(\synctest55);
}).play(AppClock);
)

This approach, with s.sync inside of a Routine, is reliable, but it does require that the server be already up and running, so this is where waitForBoot comes in. And, conveniently, if we use wait or sync without explicitly creating a Routine, then waitForBoot creates a Routine for us, automatically.

(
//alternative: waitForBoot
s.waitForBoot({
	SynthDef(
		\synctest59,
		{
			var sig;
			sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
			sig = sig.sum;
			sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
			Out.ar(0, sig!2);
		}
	).add;

	s.sync;

	Synth(\synctest59);
});
)

And I believe this auto-created Routine is played on the AppClock, which means we can freely include GUI processes in our waitForBoot function. So once again, I'll quit the server, and evaluate this code.

(
//waitForBoot with GUI
s.waitForBoot({
	~win = Window.new.front;

	SynthDef(
		\synctest65,
		{
			var sig;
			sig = {SinOsc.ar(ExpRand(300,3000), 0, 0.02)}!50;
			sig = sig.sum;
			sig = sig * EnvGen.kr(Env([0,1,0],[2,2],[1,-1]),doneAction:2);
			Out.ar(0, sig!2);
		}
	).add;

	s.sync;

	Synth(\synctest65);
});
)

And so, what you see here is basically a shorter version of the waitForBoot section in our performance code, which we'll now return to.

After adding these three SynthDefs, we'll do another s.sync to make sure the server finishes before we continue, and it's here that we will finally register take our functions ~makeNodes and ~makeEvents, and register them with ServerTree, and immediately after that, we'll do s.freeAll, which re-initializes the node tree, and thereby causes ServerTree to evaluate its registered functions. This defines our event dictionary, enables MIDI functionality, and creates our initial node tree with two groups and one Synth.

s.sync;

ServerTree.add(~makeNodes);
ServerTree.add(~makeEvents);
s.freeAll;

s.sync;

One final s.sync, and then we'll print "done" in the post window to let ourselves know when it's safe to begin a performance.

And that is the essential structure for our performance environment. So, at this point, uh, although the environment won't do anything particularly interesting or musical, we should be able to evaluate the entire thing just to verify that the basic functionality is there. So, [quit the server], [close these extra windows], put the whole thing in parentheses, cross your fingers, and hit command-enter.

Ok, I don't see any error messages, so that's a good start. And we can see the word "done" in the post window, that's also good. Let's first take a look at the node tree...and that looks perfect, we've got two groups with a reverb synth in the second group. Let's check our buffers, so if we evaluate b, it looks like our dictionary has been properly filled, and if we try to play a few buffers like this...awesome looks like that's working.

b
b[\shakers][1].play;

So now I'm going to hit command period and watch the node tree to make sure that ServerTree is actually reinstantiating our reverb synth and two groups...perfect.

~bus

Tilde bus is a dictionary containing a single stereo audio bus, so that looks correct. And finally, let's route a synth through the reverb to make sure our signal chain is intact. So here's our bpfsaw instrument with a low frequency, long release, and we're writing that signal to the reverb bus, and placing the synth in the main group.

Synth(\bpfsaw, [\freq, 1.4, \atk, 0.1, \rel, 7, \out, ~bus[\reverb]], ~mainGrp);

That sounds like reverb to me. So we are officially in good shape.

The last thing we need to do is return to the function called makeEvents, and fill it with code that creates the sounds we want for this composition. In the interest of keeping this video as short as possible, I've actually prepared this code in advance, so instead of typing it in at light speed as is usually featured in these videos, I'm just going to paste the events into our environment one-by-one and give brief descriptions as we go. Rest assured that everything in these event functions is stuff that's been seen before in this tutorial series, so there are no weird tricks or extra fancy patterns, just basic stuff. So what I encourage you to do, if you want to digest this code more thoroughly, is pause the video periodically and study the event code at your own pace, maybe copy it down and change some of the numbers around, or, experiment with making your own events functions, once you get a sense of the basic approach I'm using.

The first event starts the piece by playing two Pbinds. The first pattern creates a sustained shaker texture in which the bandpass effect is active and we randomly choose three high-pitched frequencies at which the shaker sounds resonate. The second pattern creates a sawtooth drone on MIDI note 26, the lowest D on the piano keyboard. Both of these Pbinds generate Synths indefinitely, so the next event, as we'll see in a second, will be responsible for stopping these patterns. We're also going to leave this "event1" string at the end of the function, because this means the text "event1" will appear in the post window whenever this function is evaluated. And that's convenient for keeping track of where we are in the piece, so we don't accidentally event1 twice in a row or something like that. Event1 sounds like this.

Event2 also plays two Pbinds, both of which also generate infinite-length streams. The first generates a cloud of bell tones, using this low C desk bell sample, but transposing it down between 5.5 and 7.5 semitones, and starts playback somewhere in the middle of the file, so we lose the characteristic attack transient of striking the bell. The second pattern creates a different sort of drone from our sawtooth instrument, in this case, the frequency of the oscillator is even lower, between 1 and 25 Hz, so we get an irregular, bubbly sort of texture. In this case, I don't want to stop the previous two patterns immediately, so I enclose the code for this event in a Routine. In the routine, we first start the two new patterns, then wait 4 seconds, then stop the patterns from event1. Here's what event2 sounds like.

Event3 is similar to event2, but without the Routine. First, we stop the patterns from event2, and immediately play two new patterns. The first is a lot like the bellCloud pattern, but the detune parameter is more narrow, so we get a more clear sense of pitch. The second pattern uses our sawtooth instrument, and is a simpler version of the marimba pattern from tutorial 15. The main difference is that there are fewer delta times, fewer rhythmic values, and fewer resonant frequencies to choose from. From a more large-scale perspective, events 1 and 2 are sort of less-pitched and a little more chaotic, and event3 is starting to move away from this, toward the sort of E-major B-major language we heard at the end of tutorial 15. In event3 we have pitches C# B F# C# and B in the marimba, and B in the bellTone pattern, so it's more of an open-fifth type of harmony, and we're really just getting a small taste of a more complete major key. Here's how it sounds.

In event4, first we stop the patterns from event3, and then, finally, we're ready to use the two patterns we developed in tutorial 15, so we'll just cut and paste these into our event function. And just to remind you of how it sounds, here's it is.

And, last, event5 stops these two patterns and ends the piece.

We could stop here, but something I usually like to do is add a few event functions that stop themselves automatically, and can therefore be sprinkled into the composition at will during performance. You can think of these as quote "one-shot" events. One-shot is a term usually seen used in contrast with a looped or sustained sound, and one-shot samples just play from beginning to end, only once, so I think it makes sense to appropriate this terminology here.

Our first oneshot event creates 12 synths from our sawtooth instrument, with a lot of randomization of parameters, but the fundamental frequencies are all pretty low, between 8 and 60 Hz. It's sort of like a low animal growl, and sounds like this.

Here's one-shot event number 2, which creates 15 synths using our shaker sound. The playback rate is chosen randomly from a fairly wide range, but bpfmix is set to zero, so they sound fairly similar to the original sample.

Our third and final oneshot event is a lot like the previous, but here bpfmix is set to 1, so these samples are processed by our bandpass filter, and filter's center frequencies are randomly chosen from an E-major pitch collection, so this oneshot event would harmonize well with the chords and marimba texture in event4. [play it]

I'll quit the server and run all this code again, and now instead of having to evaluate these large sections of musical event code, we can just ask our dictionary e to do the work for us.

e[\event4].value;
e[\oneshot2].value;
e[\oneshot3].value;
e[\event5].value;

But if you have a MIDI controller handy, you could use IT to trigger events instead of typing and evaluating code, if that's what you prefer. Next to my computer I've got a Korg nanoKontrol which i'm gonna plug in, and save this code file, and quit and re-open SuperCollider to make sure it actually sees this new device. Generally you want to connect your MIDI devices before launching SuperCollider. Now let's scroll up to our empty MIDIdef and see if we can just get it to just post the MIDI data the nanoKontrol is sending. Now keep in mind that I already know that my nanoKontrol sends continuous control or cc messages, that's why I'm using the dot cc method. If you have a piano keyboard controller, you can use individual keys to trigger events by just replacing .cc with .noteOn. But anyway, instead of nil, we'll declare two arguments, which are the controller value and controller number, and then just post these two values in an array. So evaluate this MIDIdef, and with an eye on the post window, we can see that the top row of buttons sends messages on controllers 73 through 81, with a value of 127 when pressed down, and 0 when released. The bottom row picks up where the top row left off, sending on controller numbers 82 through 90.

MIDIdef.cc(\controller, {
	arg val, num;
	[val,num].postln;
});

So let's use the top row for our primary musical events, and the bottom row for our one-shot events. Inside the MIDIdef function, I'm going to use a case statement, which is a handy tool for dealing with multiple conditional statements. A case statement consists of pairs of functions - a test function which returns true or false, and a second function to be evaluated if the first function is true. If the first function is false, SuperCollider moves on to the next pair of functions. To play the first musical event, here's what we want in plain english: if we press the first button in the top row down, evaluate event1 in our event dictionary. And in language that SuperCollider can understand, it looks like this. If the received message came from controller number 73, and the value of that controller is 127, evaluate the function at event1 in our dictionary e. To save time I'll paste in the other 7 function pairs, but you should be able to see at a glance that the logic is basically identical to the first line.

MIDIdef.cc(\controller, {
	arg val, num;
	case
	{num==73 && val==127} {e[\event1].value;"event1".postln;}
	{num==74 && val==127} {e[\event2].value;"event2".postln;}
	{num==75 && val==127} {e[\event3].value;"event3".postln;}
	{num==76 && val==127} {e[\event4].value;"event4".postln;}
	{num==77 && val==127} {e[\event5].value;"event5".postln;}
	{num==82 && val==127} {e[\oneshot1].value;"oneshot1".postln;}
	{num==83 && val==127} {e[\oneshot2].value;"oneshot2".postln;}
	{num==84 && val==127} {e[\oneshot3].value;"oneshot3".postln;}
	{true}{nil};
});

But what happens if we press a button that isn't one of these eight controllers? Well, who knows, right? So what I usually do is provide one final safety case with true in the first function, and nil in the second. So, even if case passes through all eight of these functions and they're all false, true will always be true, and so if case gets to the end, it does nothing. One last thing I'm gonna do is get rid of this val num postln at the top of the mididef, and tag some postlns on the end of these evaluated functions. When we trigger these events, it'll print more useful information in the post window, which will help keep our place in the piece so we don't accidentally trigger an event twice in a row or something like that. And that's it! We are done with our performance environment. For good measure, let's quit the server and re-evaluate everything, and you can sit back and relax, and I'll do a short but complete performance.

That's it for tutorial 17. As I mentioned at the beginning of this video, what you see here can be downloaded using the link in the video description below. This video showcases a simplified, and tutorial-friendly version of a personal approach to composition and performance in SuperCollider. I'm not trying to push it as a one-size-fits-all procedure, but it's worked well for me for several years, and this basic structure is usually very accommodating if you find yourself making significant changes to the piece during the compositional process. I hope you've been able to get something valuable out of this miniature three-part series, and that it's maybe shed some light on some of the more mysterious aspects of how SuperCollider works. If you've been enjoying these tutorials, I hope you'll consider liking or sharing this video, and as always, thank you so much for watching, and see you next time.