[set serial monitor to wrong rate]

Hey everybody, welcome to tutorial 19. In this video we'll take an introductory look at the Arduino platform and how it integrates with SuperCollider. Arduino is an open-source hardware/software platform for prototyping electronics, typically used for interactive projects with sensors, motors, LEDs, etc. As far as Arduino boards go, there's a pretty big variety, as we can see on the Arduino website. For this video, I'm going to be using the Mega 2560, because that's what I happen to have on hand at the moment. As you can see, it's got a USB port for connecting to a computer, which I'll do right now, and doing this also powers the board, as we can see from the little lights that come on, which is usually a good sign.

Once the hardware is connected, we can take a look at the Arduino software. You'll want to download the Arduino IDE and install it on your computer, I'll put a link in the video description below. I've got it installed on my machine already, so let's open it up. Now, the basic idea with the Arduino platform is we code a program here in the software, and then send it over to the hardware via USB, and then our code will run autonomously on the Arduino board.

So what we're looking at here is a blank code sketch, and the language of the IDE is a sort of subset of C C++, so it might look a little different if you're accustomed to SC, but there are some similarities you can see right off the bat, like functions are still delineated with curly braces, and comments preceded with a double slash, and once we start coding you'll certainly notice more syntactic similarities. So a sketch always contains two functions: void setup, and void loop. When this program runs on an Arduino board, void setup gets evaluated once at the very beginning, and then void loop gets evaluated again and again, indefinitely. Typically, stuff related to initialization goes in void setup, and anything that needs to happen repeatedly goes in void loop.

Before we start coding, though, there's a few housekeeping items we need to take care of. First, we go to the tools menu and make sure the board you're using is the one that's selected here, and in some cases you may also need to select the appropriate processor on your board. Also, you want to make sure the IDE is communicating with the correct serial port. In my case here, I want to select this one here that says usbmodem1421. Yours might look a little different depending on your operating system, but it should be fairly obvious which one you should select. If you're not sure, you can always unplug your Arduino, then go back to the port menu and see which one disappeared. And last, in order to compile and upload this code, the IDE is going to ask us to save this sketch, so we might as well take a second to do that now.

Now, before we connect any sensors, I want write an exceedingly simple program just to verify that the Arduino and laptop are successfully communicating with each other. So in the void setup function, I need to initialize serial port communication. This is done with Serial.begin(), and in parentheses, providing the transmission rate in bits per second. And this is probably a good time to talk about accessing the help documentation -- you can click or highlight any class or method, and then under the help menu, choose Find in Reference, or use the hotkey, which in my case is shift-command-F. So here's the page for Serial, and on the right we can see the available methods, so let's click on begin. And the help file says for computer communication we need to use one of these rates, and I usually just go with the highest option 115200, because why not. Techically I think it's possible to go even higher than this, but we'll just stick with this because it's plenty fast for what we're gonna be doing. And, while we're on the topic of helpful documentation, I'll also point out that in the file menu, there's a large collection of examples, which can be really helpful for getting a sense of the syntax and what a typical Arduino sketch might look like.

So, then, down in void loop, we're going to use Serial.print, which tells the Arduino to write a value to its serial port, and we'll just print the character a. And that's all I'm gonna do for now. So when we're done coding, we click this check button to verify or compile the code, which checks to make sure there are no errors, and then we click this right arrow button to upload it to the Arduino. Notice that when the Arduino receives a new program, the lights on the board usually do a little dance, so I usually keep an eye out for that just to make sure everything is communicating properly.

So now, what should be happening, though you can't really tell by looking at the Arduino, is the board should be spewing forth a barrage of the letter a along the USB cable. And we can check whether this is the case using a very handy built-in tool called the serial monitor. We can access the serial monitor from the Tools menu, or using the hotkey shift-command-m, or clicking the magnifying glass button in the upper right corner of the sketch. And we see...what appears to be gibberish...that's not the letter a. This nonsense is because the serial monitor is running at a different rate than the one we used to program the Arduino, and these rates have to match, otherwise the data becomes garbled. So that looks correct, the board screaming away with a ridiculous torrent of a's as fast as it can. In fact, it would probably be sensible to have the Arduino pause for a bit between sending out each a, basically give it some breathing room. We can do this by introducing a delay into the void loop function, and providing a delay time in milliseconds. Once we've done that we upload the code again, and this overwrites whatever code previously existed on the Arduino. So, now in the serial monitor, we see an 'a' once per second.

So the Arduino and laptop computer are communicating, that's a very important step that we've now taken care of. So let's break out the toys. For this video I have a half-size breadboard, a photoresistor which exhibits a decrease in resistance as light exposure increases, a 10kΩ through-hole resistor, and a few jumper cables.

Let's talk about the breadboard for a second for anyone not familiar with how they work. The outside a breadboard looks something like this, with a whole bunch of holes, and on the inside, the holes are connected according to the green rectangles you see here. This means if you plug some signal into hole a1, you can connect to that signal through hole b1, c1, d1, and/or e1 and continue building your circuit from there. Likewise, if you plug something into a long rail marked with a red plus, you can copy that signal by connecting a wire to any of the other holes along that rail.

And a quick word about this 10k resistor here. Resistors come in a variety of resistances, and you'll want to use resistors that are appropriate for the sensors and circuits you're using. What I usually do is search for a schematic diagram or so-called hookup guide on the web for the sensors I'm using and make a decision based off that. For example, this diagram on adafruit.com recommends using a 10k resistor in this voltage divider circuit.

https://learn.adafruit.com/photocells/using-a-photocell

If you happen to come across a random resistor, you can always determine resistance by reading the color bands and comparing them to a resistor color code chart, like the one I have here. Now, it's probably difficult to see clearly, but the color bands here are brown, black, orange, and gold. Looking at the chart, brown and black translate to the digits 1 and 0, which gives us the integer 10, orange is the multiplier, which is 1000, so 10 times 1000 is 10,000, so that's how I can be sure this is a 10 kilo-ohm resistors. The gold band refers to the tolerance, which I think is how much you can expect the resistance to deviate from how it's marked, so the resistance is probably not exactly 10k.

So let's build a circuit that incorporates this photoresistor. I could use the diagram here, but I'm actually going to use the schematic from this analog input tutorial on the arduino website. It's actually the same thing, I just think this one is a little easier to read.

https://www.arduino.cc/en/Tutorial/AnalogInput

This is a simple voltage divider circuit which is a very common thing to see when working with sensors and Arduino. We start at the 5V source on the board, connect it to one side of the photoresistor. Then, on the other side, we sample this voltage by connecting it to an analog input on the board, the lowest one is marked A0. Continuing along the circuit, we go through a fixed 10k resistor, and connect the other side of that resistor to ground.

So let's build it. On the board, find the hole marked 5V and using a jumper cable, connect that to one of the rows on our breadboard. One of the pins on our photocell goes into this same row, ande the other pin into a different row, and then we connect this side of the photocell to analog input 0, using another jumper cable. Then a 10k resistor from this row to yet another row, and ground this third row, connecting it to a hole on the Arduino marked GND. A lot of arduinos have multiple ground holes, and it doesn't matter which one you use.

So with the circuit complete, let's write some code to digitize the voltage coming out of this photocell and send it to the laptop. We don't need to change Serial.begin, that's fine as it is, but at the very top of the code, actually outside of the void setup function, let's declare an integer called value and this'll be used to store the value that the arduino reads at analog input zero. And you might think, well why don't we declare this value in void setup? Why do we have to do it outside? Isn't that what void setup is for? And the answer is that if we were to declare it inside void setup, then its scope would be limited within void setup, and we wouldn't be able to access this variable inside void loop. So a declaration like this at the very top of the code is the right thing to do.

Down in void loop we'll grab the voltage at analog input zero with value equals analogRead, parenetheses, zero. After we've done this, we simply want to write it to the serial port using Serial.print - value. In fact, to make this more human readable at the serial monitor, I'll use println instead of print so that the arduino appends each value with a new line. And then a small delay is probably a safe thing to do, so let's pause for one millisecond. Verify the code, it looks to be error-free, that's good, upload, and we'll now check the serial monitor. And as you can see, values decrease when I block out the ambient light, and increase when I shine a flashlight onto the photocell.

So now, the last major step is getting SuperCollider to listen to the USB port, instead of the serial monitor. First we need to quit the Arduino software, because only one process can use a serial port at one time. And that's fine because the IDE has done its job -- we've written our code and uploaded it to the Arduino board. So in SuperCollider, we start with a class called SerialPort.

SerialPort

We want make a new instance of SerialPort, give it a name, and the first argument for dot new is a string representing the name of the port. SerialPort.devices returns an array of available ports, in fact, this is the same list of ports we saw in the arduino IDE. So, we can copy the relevant port name, and paste it as the first argument for SerialPort.new, and adding double quotes around it. The second argument is transmission rate, this has to match the rate we've chosen for the Arduino, and that's 115200. And that's all we need for this line, so let's run this line.

~port = SerialPort.new("/dev/tty.usbmodem1421", 115200);

Using this new instance of SerialPort, we can get values from the usb connection with the read method. So let's run this a few times

~port.read;

And, looking at the post window, a very reasonable thought to have is ... what are these bogus numbers. They're totally not the same numbers we saw on the serial monitor, and they don't seem to be correlated with anything in particular

But, ok before we jump to any conclusions, let's use an iterative process, like do, to get a rapid-fire sequence of values from the serial port, because remember, the Arduino is sending values out very quickly, with only a 1 millisecond delay in-between. So with this line, we're essentially guaranteeing the values we get are, in fact, sequential.

30.do{~port.read.postln};

And, ok to be fair, this approach doesn't really clear anything up, it's still kind of a mystery where these numbers are coming from, however, at this moment, I want to go back into the Arduino reference files and look at Serial.print. The key sentence here is "Numbers are printed using an ASCII character for each digit." ASCII is an encoding standard through which text characters are represented by numerical values. One of the quickest ways to understand what's going on is to look at an ASCII code chart like this one. For example, the decimal number 90 represents the character capital Z, 91 represents the left square bracket character, etc. SuperCollider has no problem decoding these, using the method asAscii

90.asAscii;
91.asAscii;

So with that in mind let's run this code again, but this time, instead of posting individual values, we'll store the values in an array.

(
x = [];
30.do{x = x.add(~port.read)};
)

x;

And now the array x is filled with 30 sequential values from the serial port, which we now know represent characters. So we can collect over this array and use the asAscii method to convert each value into the character it represents.

x.collect(_.asAscii);

And ahh, now things are starting to make more sense. Let's take a look at the unconverted array and compare it to our ASCII chart.

x;

So, we have the sequence 55, 51, 56, which corresponds to the characters 7, 3, and 8. That’s followed by the sequence 13 10, which corresponds to a carriage return, and a new line. Then, this pattern of five numbers repeats, which explains the appearance of the converted array below.

So now that we have a better understanding of how values make their way from the Arduino board into SuperCollider, I want to return to the Arduino IDE to make a subtle change. The main reason for this is we do need some sort of delineator so that SC will know where one value ends and the next begins, and technically we do already have that here, it's our 13 10 sequence that represents a carriage return and new line, but I don't really like that there are two discrete characters to delineate a break, that seems redundant to me. So in SuperCollider, let's close the port so that the Arduino IDE can use it,

~port.close;

And in the IDE, we're going to use print instead of println for our photocell value, doing this will remove our carriage return and new line from the sequence of ascii code, and instead, after printing the value we will Serial-print the character lowercase a, upload this to the board, and in the serial monitor, well, we can sort of make out a bunch of numbers and the letter a all jumbled together in a beautiful mess. Yes it looks like complete madness but also it looks correct.

So quit the Arduino IDE and back in SuperCollider, let's re-instantiate our port object,

~port = SerialPort.new("/dev/tty.usbmodem1421", 115200);

and let's read a new sequence of 30 ASCII values converted to characters

(
x = [];
30.do{x = x.add(~port.read)};
x = x.collect(_.asAscii);
)

And this looks correct. We've got a three digit number, the letter a, another three digit number, the letter a again, and so on. So with this alphabetic character as our value delineator, we don't have to worry about dealing the two non-printing characters we had previously. Now this change I just made is not strictly necessary, but I sort of think dealing with only letters and numbers, is a little cleaner and simpler when it comes to writing the code that handles this data. Speaking of writing code that handles this data, we've just been grabbing 30 values at a time, but now let's actually write a looping process that continuously grabs values from the USB port and converts them into usable numerical data, because keep in mind, the numbers we're seeing in the post window are not actually members of the integer class, they are all characters,

x.collect(_.class);

and mathematically, and sonically, characters are totally useless, we're definitely going to have to find a way to convert characters into true numbers.

So, anyway, when we want some process to loop, Routine is a good choice, which you may remember seeing in the middle of tutorial 17. So here's a new routine with globally accessible name, dot play. Inside the routine, curly braces dot loop. So, first things first, inside the loop, read the next value from the port and convert it to an ascii character, and we'll just call this value ascii. Now there's really no need for this to be a tilde environment variable, because we aren't going to be using it outside of this routine, so we'll make this a local variable, which means we have to declare it right inside the top of the routine.

(
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;

	}.loop;
}).play
)

Once we've got our ascii character, we'll need some conditional logic, because what we do next is gonna depend on whether this character is a number or the letter a. Using methods found in the Char help file, we can ask a character things like are you an alphabetic character, are you a character that actually prints something, are you punctuation, etc. So, for example, the character lowercase a, we create characters in SC by preceding them with a dollar sign, character a dot isAlpha returns true, but character 4 is not an alphabetic character. That's false.

$a.isAlpha;
$4.isAlpha;

Right, so if this character is a decimal digit, then, add it to an array. And let's initialize this charArray as an empty array at the top of this clump. If this character is lowercase a, we want to convert this array of characters into a usable integer, and then empty out the array so it's ready for the next set of characters.

(
~charArray = [];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {});

	}.loop;
}).play
)

So, okay, how do we convert a collection of individual numerical characters into a single, multi-digit integer? For example, if we have the array of characters 4, 6, 1, how to we turn this into the integer 461?

[$4, $6, $1] ==> 461 ??

Well, this is actually kind of a fun exercise, so if you want, feel free to pause the video and try to work this one out yourself, there's probably a few ways this can be done. So we want to wave a magic wand and turn this into this. First, we collect over the characters and use the digit method, which converts characters to integers. In the post window, it doesn't look any different, but with the class method, you can see that this array now contains integers. Now, we can do it in the following way -- reverse the array, multiply each integer by ten raised to the power of that integer's index within the array, and then sum the contents of the array...which is fine, but it's a little long, and definitely not as simple as the alternative, which is to use the method convertDigits.

[$4, $6, $1];
[$4, $6, $1].collect(_.digit);
[$4, $6, $1].collect(_.digit).collect(_.class);
[$4, $6, $1].collect(_.digit).reverse.collect({arg n,i; n*(10.pow(i))}).sum;
[$4, $6, $1].collect(_.digit).convertDigits;

Ok, back to our routine, if we have a lowercase a, tilde val, this is where we'll store the integer result, equals charArray dot collect, convert characters to integers, dot convertDigits. And then, empty charArray. And, now, we are ready to play this routine.

(
~charArray = [];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~charArray = [];
		});
	}.loop;
}).play
)

So with this routine running in the background, let's evaluate tilde val,

~val;

this looks correct, and of course, the final test, manipulate the photocell while checking the incoming value. So, covered up,

~val;

and with flashlight...

~val;

success! Now, if you're sharp, you might have looked at this looping routine and thought to yourself, wait a minute, that loop doesn't pause between evaluations, so it's running unrestrained, as fast as possible, why doesn't it crash the interpreter? In fact, if we take a look at the macOS activity monitor utility, we can see that SC seems to be not struggling at all. Now, if you spotted this, A+, it's an excellent observation, and this fairly subtle idea had me stumped for quite some time. I think this is worth explaining in a little more detail, so first, let's stop this routine.

~getValues.stop;

In SC, if you have a looping routine, and include a wait time as we do here, you're probably gonna be fine.

(
~r = Routine.new({
	{
		rrand(0,9).postln;
		0.25.wait;
	}.loop
}).play
)

~r.stop;

If you don't include a wait time, sclang will almost certainly crash. Now, this might be disappointing, but I'm not actually gonna run this code, because it's a real drag to force quit SC, re-open it, reinitialize everything, especially with all this audio video recording software running in the background, and it might screw some other stuff up, so just take my word for it, this will crash sclang and you will have to force quit, it'll be a mess and you'll be very sad.

(
~r = Routine.new({
	{
		rrand(0,9).postln;
		//0.25.wait;
	}.loop
}).play
)

~r.stop;

Now, this getValues routine has a loop, but no wait, so why doesn't it crash? Here is my understanding which admittedly, may not be completely accurate, but I think I get the idea. In the SerialPort help file, there are actually two methods that read from a port, next and read. We've been using read, which is "blocking". Next is a "non-blocking" method. So, what's the difference, what is blocking? In this context, blocking refers to pausing evalutation of the current thread, and in this case the current thread refers to our routine loop, and it blocks that thread from continuing until it returns from the serial port with the next value. On the other hand, next does not block the current thread. It goes to the serial port looking for a value, but the routine keeps blasting away as fast as it can, and depending on how fast the Arduino is spitting out values, port.next may come back empty handed or maybe the value hasn't changed yet and it'll come back with the same value as the previous call. So, if we were to use next instead of read in this routine, then we would definitely expect sclang to crash. But with read, remember that we built a 1ms delay time into the Arduino loop, so let's say our routine is running, we get to ~port.read, and ~port.read says to the routine, ok hang on, hold everything, I'm going to the serial port, and let's say it gets there and the Arduino happens to be in the middle of its 1ms delay. So port.read waits...and waits until the arduino finishes that delay and goes through another Serial.print. Then port.read takes that value, brings it back to SC and says to the routine here you go, you may proceed. So this is actually pretty cool, we've got a small delay time on the Arduino and using the read method, we're able to carry that delay with us back into SC and implicitly include it in this routine. So that's why this particular loop doesn't crash the interpreter.

(
~charArray = [];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~charArray = [];
		});
	}.loop;
}).play
)

Ok, so finally we'll use these photocell values to manipulate sound. Here's a simple SynthDef that applies a resonant lowpass filter to a stereo sawtooth wave with slightly different frequencies between the left and right channels, and the cutoff frequency is declared as an argument, so we can control this value externally. I've also used lag to smooth the cutoff values by a window of 0.02 seconds, because if we use the discrete digitized photocell values directly, we might introduce some audible discontinuities or artifacts into the sound.

s.boot;

(
SynthDef.new(\saw, {
	arg cutoff=1000;
	var sig;
	sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(0, sig);
}).add;
)

It sounds like this:

~synth = Synth(\saw, [\cutoff, 200]);
~synth.set(\cutoff, 10000);
~synth.free;

To control a synth using the photocell, we just need another looping routine that applies photocell values to the cutoff argument of a running Synth. Here's our basic looping structure, and inside, set the cutoff of the Synth using our photocell value. The Arduino employs a 10-bit analog to digital converter, so tilde val could be as low as 0, and as high as 1023, but usually somewhere in between. This range of values is almost ok as-is, but technically it could go down to zero, and when used as the value for the cutoff frequency of a resonant filter, that's shall we say, an explosive value. So we'll use linexp to map from the linear range 0 to 1023 onto the exponential range, uh, let's say 80 to 4000. And then, as explained earlier, we have to include a wait time within this loop, so we don't crash, let's go with 0.01 -- not so large that the photocell will feel unresponsive, but also not so small that sclang will get overworked.

So, create the synth, and play the routine.

~synth = Synth(\saw);

(
~control = Routine.new({
	{
		~synth.set(\cutoff, ~val.linexp(0,1023,80,4000));
		0.01.wait;
	}.loop
}).play
)

When you're done, simply stop the routine, and free the Synth.

(
~control.stop;
~synth.free;
)

And as far as the basics are concerned, that's really all there is to it. This is just one analog sensor, but there's no reason you can't connect others along with buttons and potentiometers, and you could maybe create some sort of miniature control surface or pseudo-synthesizer. With Arduino, the possibilities are just really, really vast, but thinking up cool projects for yourself is part of the fun of microcontrollers, frankly. Now, the SuperCollider code in this video could certainly be modified and made a bit more elegant, and obviously this sound could be a little more interesting and complex, but for this video I wanted to focus on just the absolute bare essentials, only what you'd need to get everything up and running properly. As I was writing this tutorial, I was considering rewiring the breadboard and showing other types of sensors, but I was concerned the tutorial would get a little too long, that I'd just end up repeating a lot of the same stuff, and it might also be hard to see exactly what's going on at the breadboard if things got too crazy. And maybe there will be an intermediate SC-Arduino tutorial down the road at some point, who knows. Anyway, that's it for tutorial 19. I enjoyed making this tutorial, I hope you enjoyed watching it, I hope you got something valueable out of it, if so please consider giving the video a thumbs up and subscribing, feel free to leave any comments or questions below, and as always, thank you so much for watching. See you next time.