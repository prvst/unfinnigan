# Introduction #

The purpose of this parser is to serve as an exploration aid. It is based on [Hachoir](http://bitbucket.org/haypo/hachoir/wiki/hachoir-core), a very potent file forensics library written in python.

# Installation #

## 0. Get Hachoir ##
### 0.1 Temporary setup (in a perishable environment) ###
There may be a better way to do it, but I not familiar with python and do not know how to install modules allowing local overrides. This suggestion is based on my experience and on the assumption that you will be hacking on the Finnigan parser and therefore will need to install Hachoir somewhere where you can easily add files to it.

I suggest that instead of installing it properly, you simply check it out into any directory and then simply source its environment variables into your shell before setting out to with it. One advantage of this method is that you can simply wipe the Hachoir directory once you are no longer interested in it and not bother about cleaning your environment.

Otherwise, read the Hachoir documentation about installing it in your private user space (or see note 0.2 below).

If you know how to override a system-wide installation to include an private add-on to Hachoir, please let me know.

The simplest procedure is:

```
cd ~
hg clone http://bitbucket.org/haypo/hachoir/
cd hachoir
. setupenv.sh
```

From now on, as long as you have this shell session running, you should be able to run Hachoir tools from it. Test them like so:

```
hachoir-metadata /usr/share/sounds/pop.wav
hachoir-urwid /usr/share/sounds/pop.wav
```

### 0.2 Permanent setup ###

This installation procedure worked on a fairly old RHEL server (but failed on its contemporary Fedora 10).

#### Update your environment ####

Edit your profile (`~/.bash_profile`, or `~/.bashrc` -- wherever you store these things) and make sure that your both your `PATH` and `PYTHONPATH` variables point to `~/hachoir`:

```
PATH=$HOME/bin:$HOME/hachoir:/opt/bin:$PATH
export PATH
export PYTHONPATH=$HOME/hachoir
```

When done, source the profile, _e.g._:
```
. ~/.bashrc
```

#### Install from source ####
```
  mkdir -p ~/hachoir
  mkdir -p ~/src
  cd ~/src
  hg clone http://bitbucket.org/haypo/hachoir/
  cd hachoir/hachoir-core/
  ./setup.py install --install-script=$HOME/hachoir --install-purelib=$HOME/hachoir
  cd ../hachoir-parser
  ./setup.py install --install-script=$HOME/hachoir --install-purelib=$HOME/hachoir
```

If `setup.py` fails with this message:

```
IOError: [Errno 2] No such file or directory: 'README'
```

create a `README` file and re-run it:

```
touch README
./setup.py install --install-script=$HOME/hachoir --install-purelib=$HOME/hachoir
```

Then repeat the install step in `hachoir-wx` and `hachoir-urwid`:

```
cd ../hachoir-wx
./setup.py install --install-script=$HOME/hachoir --install-purelib=$HOME/hachoir
cd ../hachoir-urwid
./setup.py install --install-script=$HOME/hachoir --install-purelib=$HOME/hachoir
```

#### Make sure wx is installed ####
`hachoir-wx` requires wx-python, so I had to do

```
sudo yum install wxPython
```

before I could run it. After that, it worked.

### Urwid ###
To make `hachoir-urwid` work, you need the `urwid` library. It will allow you to browse files with hachoir in a tty terminal. Now that I am in Ubuntu, I had to install the `python-urwid` package.

## 1. Add the Finnigan parser to your Hachoir ##
```
cd ~
hg clone https://unfinnigan.googlecode.com/hg/ unfinnigan
```

### If your Hachoir setup is temporary (you did not run setup.py): ###
```
cd ~/hachoir/hachoir_parser/hachoir_parser/misc/
```

### Else if it was set up with setup.py: ###
```
cd ~/hachoir/hachoir_parser/misc/
```

### Or, if your Hachoir is installed system-wide: ###
```
sudo -i
cd /usr/share/pyshared/hachoir_parser/misc/   # in Ubuntu
```


### Now link the Finnigan parser in: ###
```
ln -s ~/unfinnigan/finnigan.py .
```

Now the parser is in the search path, but in order for Hachoir to be aware of it, it also needs to be added to its imports. Open the file `~/hachoir/hachoir_parser/misc/__init__.py` and add this line to it:

```
from hachoir_parser.misc.finnigan import Finnigan
```

To modify the temporary setup, edit `~/hachoir/hachoir_parser/misc/__init__.py`
## 2. Test it ##

```
hachoir-urwid drugx_15.raw  # a sample file that comes with Xcalibur
```

You should see something like this:

```
0) file:/home/selkovjr/drugx_15.raw: Raw data collected from a Thermo mass spectrometer (193.1 KB)                    
 + 0) file header: The root file header (magic 1) (1356 bytes)
 + 1356) run header: The run header with information about the number of scans (916 bytes)
 + 2272) seq row: SeqRow -- Sequence Table Row (436 bytes)
 + 2708) raw file info: Something called RawFileInfo -- meaning unknown (120 bytes)
. . . .
```

You can now navigate the structure of your Finnigan raw file with `hachoir-urwid`. Also, try `hachoir-wx`, if you are working in a graphical environment (such as X11)

## 3. What does it all mean? ##

Because `finnigan.py` is not yet part of the Hachoir distribution, it must be hooked up to it before you can use it. Wherever your Hachoir is installed (and it may already be included as a package in your system distribution), the easiest way to add the Finnigan parser to it is by placing a symlink to `finnigan.py` in Hachoir's `misc` directory, as we have just done. The link can point to any location where you prefer to keep (and possibly work on) your copy of `finnigan.py`.