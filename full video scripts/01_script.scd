Hi everyone, and welcome to the first tutorial. In this video I'll discuss navigating the SuperCollider environment as well as some basic programming concepts.

When you first open SuperCollider, this is what you'll see. On the left is your workspace. This is where you'll type and evaluate code, and this code is what will be written to a file when you save your work. On the lower right is the post window. This is where SuperCollider communicates with the user, by posting either the result of evaluated code, or an error message in response to invalid code. And on the top right is the help documentation.

The post window and help documentation can both be moved and repositioned by clicking and dragging their top bar, like so. They can be undocked or detached by clicking the icon at the upper left of each component. If you choose to detach a component, then it becomes a standard window which can move between the foreground and background. If you close a component, it can be re-opened by clicking on the View menu and selecting Docklets.

Unlike some previous versions of SuperCollider, there is now a preferences dialog under the SuperCollider menu. Here you can modify the appearance and behavior of the text editor, customize keyboard shortcuts, and a few other things.

Let's take a look at the post window, where you can see that there's been some activity. Specifically, on startup, SuperCollider will try to compile the class library, and load the help files. Here we can see the library has been successfully compiled, and the help documents have been successfully indexed. Here, and in many other situations, you'll find it very useful to be able to clear the post window. To do this, right click on the post window, and you'll see an option to Clear. You'll probably also see a keyboard shortcut next to the word Clear. I suggest memorizing this keyboard shortcut, because you'll probably be using it a lot.

Let's now move on to the workspace to start writing and evaluating code.

The SuperCollider language is home to a library of classes, which represent different types of data. Inputs, outputs, computation, and other types of data manipulation are conceived as messages that are passed to objects. When an object receives a message, it is said to be the receiver of that message. The most commonly used syntax for this receiver-message paradigm is

receiver-dot-message

messages are sometimes called methods, and these two words are used interchangably.

In the following example, 3 is the receiver of the message "cubed". In order to execute this statement, we simply place the mouse cursor anywhere on this line and press shift-return. The result of this evaluation is printed in the post window.

To demonstrate error messages, let's suppose we've misspelled "cubed". If we try to evaluate, the post window displays an error message. It looks complicated, but if we scroll to the top, we can see that SuperCollider was unable to understand the message "cudeb". Let's clear the post window and imagine a different flavor of misspelling, like typing a comma instead of a period. In this case, SuperCollider reports a syntax error. There are several different types of error messages, some of which take some time to decipher and debug, but in most cases, it will be a simple misspelling, an extra character, or a forgotten parenthesis.

Let's clear the post window and discuss the use of variables. A variable is a named container that's used to store a value, not necessarily a number, so that it can be referred to later. For instance, we can store the value of 3.cubed in the variable "x", like so.

x = 3.cubed;

Evaluate this line, and "x" now holds a value of 27. We can now continue to do operations with x, if we so choose. For instance, x+10 returns 37. Let's change our variable name from "x" to "number"

and if we evaluate, we get an error message saying that the variable "number" is not defined. This brings up an important concept. In SuperCollider, there is a distinction made between local variables and global variables. Local variables must be declared before they are used, using a "var" statement like so:

var number;
number = 3.cubed;

local variables must begin with a lowercase alphabetic character, but after the first character you can use uppercase letters, numbers, hyphens, and underscores. Notice that now we're dealing with multiple statements of code, so each statement must end with a semicolon. There are several ways to evaluate multiple statements simultaneously. You can highlight everything and press shift-return, or easier still, you can enclose your code in parentheses, place the mouse cursor anywhere between them, and press command-return.

(
var number;
number = 3.cubed;
)

Notice that even though this code has compiled with no errors, the variable "number" is now lost, since it was a local variable.

Notice also that we can't run these statements one-at-a-time; local variables must be declared and used within the same code execution.

Global variables, on the other hand, persist after code evaluation. Lowercase a through z are reserved for use as global variables, or you can precede a local variable name with a tilde in order to turn it into a global variable. So we could set ~number equal to 3-cubed, and we'd have no errors.

Technically speaking, global variables are actually environment variables, which means they are specific to a particular environment. But for the beginner, it's fine to conceive environment variables as being globally accessible.

When dealing with many statements of code, you might often see a single variable being continually overwritten as a piece of data is continually manipulated, like so:

Here, we declare a variable called foo, set it equal to three, cube it, add 100, and divide by two. For the last line, we simply output the foo's value.  In each statement, we set "foo" equal to the result of the newly manipulated data.

(
var foo;
foo = 3;
foo = foo.cubed;
foo = foo + 100;
foo = foo/2;
foo;
)

We see in the post window that the result is 63.5. If we were to remove these overwritings, like so (pause), we'd still be computing values, but foo would not keep track of these computations. Hence, when we evaluate this clump, we see foo's original value of three, which has not changed.

(
var foo;
foo = 3;
foo.cubed;
foo + 100;
foo/2;
foo;
)

Notice that the original clump can be mathematically rewritten like so (pause), demonstrating that methods and operations can be strung together on a single line, always evaluated from left to right. Notice that there is no mathematical operator preference, that is to say, the addition is done before the division. Although this is syntactically legal, I would argue that the multi-line approach is more clear.

3.cubed + 100 / 2;

As your code gets longer and longer, I strongly advise that you include comments. A comment is a piece of text that's invisible to SuperCollider, that's used to clarify your code in human terms, so that, for instance, someone you're collaborating with can understand what your code is attempting to do. Comments are also useful if you return to a complicated piece of code you've written several years ago and need to remind yourself what it's all about.

A single-line comment is always preceded with two forward slashes, like so,

and a multi-line comment is preceded by slash-asterisk, and appended with asterisk-slash. By default, comments are red.

To close out this tutorial, I'll talk just a bit more about the help documentation.

cubed

To get help, place the cursor on the text you'd like to look up, click on the Help menu at the top, and choose look up documentation for cursor. The keyboard shortcut for this is command-d. In this case, SuperCollider searches its help documents for the word "cubed", and it comes up with a method called cubed, which is defined for several different classes, like SequenceableCollection and SimpleNumber. You can bring up a search bar by selecting "look up documentation" in the Help menu, and type whatever you like. The shortcut for this is shift-command-d. In this case, I've typed oscillator, and SuperCollider returns all the help files that contain the word oscillator. You can do a find for text within the current help document using the search bar in the upper right corner, and you can navigate forward and back through the help documentation, just like you would on a web browser.

That's it for this tutorial. In the next video we'll start making some sound. Thanks for watching.

