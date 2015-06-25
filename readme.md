# XBConsole
###Info
XBConsole is a Swift port of a class that is used to remotely read and write, and other various functions (search XBDM) on a modified XBOX 360 console. 
###Usage
1) Initialize your console, the only input parameter is the IP of the console on your local network. 
<pre><code>var console = XBConsole("192.168.0.110")</code></pre>
2) Connect to the console
<pre><code>console.connect()</pre></code>

###Methods

####getMemory(address: Int, length: Int)
Gets memory at 'address' with the size of 'length'
####setMemory(address: Int, buffer: [UInt8])
Sets the contents within 'buffer' to the address specified by 'address'

##Issues and Contact
There are no known issues, I've stress tessed and this works flawlessly. If there is an issue, feel free to create a bug report and I will investigate.