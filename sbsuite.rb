#!/usr/bin/ruby
# Ruby script to do all sorts of SlackBuild-related
# things for you!  Just run and gun!  Or something
# along those lines.
#
# Written by JK Wood <joshuakwood@gmail.com>
#
# sbsuite is released under the Dog-on-Fire License:
# If use of sbsuite causes your dog to catch on fire,
# you agree to send me five dollars.  Or a picture
# of the dog on fire.
# Otherwise, you're on your own.  I've tested sbsuite
# on my own computer, and it hasn't broken anything.
# So if it does it on your computer, that falls in
# the realm of "Not my problem."
#
# Of course, if you'll send a bug report to the above
# email address, I may be able to see what you did
# wrong and prevent it from happening in the future.
# In which case, I may just send YOU five dollars.

# CHANGELOG:
# 11222008: Initial version 1.0
# 01112009: Version 1.01, fix find bug, add CHANGELOG
# 01192009: Version 1.02, fix PRGNAM bug
# 01212009: Version 1.03, fix no = in i486 SLKCFLAGS
# 03112010: Update for 13.0 
# 04152010: Fix missing comma - thanks wario

# You'll be wanting to put your own info here.
# Otherwise, people will know that you didn't
# edit the script.  And that would be embarassing.
$AUTHOR = "I"
$EMAIL = "didn't"
$ARCH = "edit"
$TAG = "the"
# Feel free to comment the next line out if
# you're making builds for Slackware.
$DISTRO = "script"

if $DISTRO
  $PKGARCH = $ARCH + "_" + $DISTRO
end

# I think all programs/scripts should have Usage statements.
def usage
  puts 
  puts "Usage: #{$0} PROGNAME VERSION SRCARCHIVE HOMEPAGE DOWNLOAD"
  puts 
  puts "   sbsuite is a program for doing all sorts of neat" 
  puts "   things with SlackBuilds.  Creating them, along "
  puts "   with the stuff that goes along with them."
  puts 
  puts "   Yeah, that's a lot of stuff for a command line."
  puts "   The good news is, it makes for a lot less work."
  puts
  puts "   Bug JK Wood <joshuakwood@gmail.com> if you have"
  puts "   problems."
  exit
end

# This method actually creates the SlackBuild file.
def makeBuild
  slackbuild = $PRGNAM + ".SlackBuild"
  slackbuildtext = ["#!/bin/sh",
                    "# Slackbuild for #{ $PRGNAM}",
                    "# Written by #{ $AUTHOR } <#{$EMAIL}>",
                    "",
                    "PRGNAM=#{$PRGNAM}",
                    "VERSION=#{$VERSION}",
                    "ARCH=${ARCH:-#{$ARCH}}",
                    "BUILD=${BUILD:-1}",
                    "TAG=${TAG:-_#{$TAG}}",
                    if ($DISTRO)
                        "DISTRO=${DISTRO:-#{$DISTRO}}"
                    end,
                    "CWD=$(pwd)",
                    "TMP=${TMP:-/tmp/SBo}",
                    "PKG=$TMP/package-$PRGNAM",
                    "OUTPUT=${OUTPUT:-/tmp}",
                    "",
                    "if [ \"$ARCH\" = \"i486\" ]; then",
                    "  SLKCFLAGS=\"-O2 -march=i486 -mtune=i686\"",
		    "  LIBDIRSUFFIX=\"\"",
                    "elif [ \"$ARCH\" = \"i686\" ]; then",
                    "  SLKCFLAGS=\"-O2 -march=i686 -mtune=i686\"",
		    "  LIBDIRSUFFIX=\"\"",
                    "elif [ \"$ARCH\" = \"x86_64\" ]; then",
                    "  SLKCFLAGS=\"-O2 -fPIC\"",
		    "  LIBDIRSUFFIX=\"64\"",
                    "fi",
                    "",
                    if ($DISTRO)
                      "PKGARCH=${ARCH}_${DISTRO}"
                    end,
                    "",
                    "rm -rf $PKG",
                    "mkdir -p $TMP $PKG $OUTPUT",
                    "cd $TMP || exit 1",
                    "rm -rf $PRGNAM-$VERSION",
                    "tar -xvf $CWD/$PRGNAM-$VERSION.tar.#{if $SRC[-2..-1] == 'gz'; 'gz'; else; 'bz2'; end} || exit 1",
                    "cd $PRGNAM-$VERSION || exit 1",
                    "chown -R root:root .",
                    "find . \\( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \\) \\",
                    " -exec chmod 755 {} \\; -o \\",
                    " \\( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \\) \\",
                    "  -exec chmod 644 {} \\;",
                    "",
                    "CFLAGS=\"$SLKCFLAGS\" \\",
                    "CXXFLAGS=\"$SLKCFLAGS\" \\",
                    if ($DISTRO == "slamd64") 
                        "LDFLAGS=\"-L/lib${LIBDIRSUFFIX} -L/usr/lib${LIBDIRSUFFIX}\" \\"
                    end,
                    "./configure \\",
                    "  --prefix=/usr \\",
                    "  --sysconfdir=/etc \\",
                    "  --docdir=/usr/doc/$PRGNAM-$VERSION \\",
                    "  --mandir=/usr/man \\",
                    "  --libdir=/usr/lib${LIBDIRSUFFIX} \\,"
                    "  --build=$ARCH-slackware-linux \\",
                    "  || exit 1",
                    "",
                    "make || exit 1",
                    "make install-strip DESTDIR=$PKG || exit 1",
                    "",
                    "find $PKG | xargs file | grep -e \"executable\" -e \"shared object\" | grep ELF \\",
                    "  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true",
                    "",
                    "(",
                    "  cd $PKG/usr/man || exit 1",
                    "  find . -type f -exec gzip -9 {} \\;",
                    "  for i in $(find . -type l); do ln -s $(readlink $i).gz $i.gz ; rm $i ; done",
                    ")",
                    "",
                    "mkdir -p $PKG/usr/doc/$PRGNAM-$VERSION",
                    "cp -a CHANGES COPYING CREDITS README TODO \\",
                    "  $PKG/usr/doc/$PRGNAM-$VERSION",
                    "cat $CWD/$PRGNAM.SlackBuild > $PKG/usr/doc/$PRGNAM-$VERSION/$PRGNAM.SlackBuild",
                    "find $PKG/usr/doc -name \"Makefile\" -exec rm {} \\;",
                    "find $PKG/usr/doc -type f -exec chmod 644 {} \\;",
                    "",
                    "mkdir -p $PKG/install",
                    "cat $CWD/slack-desc > $PKG/install/slack-desc",
                    "cat $CWD/doinst.sh > $PKG/install/doinst.sh",
                    "",
                    "cd $PKG",
                    "/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$#{if ($PKGARCH); "PKG"; end}ARCH-$BUILD$TAG.tgz" ]
  
  File.open slackbuild, "w" do |f|
    slackbuildtext.each do |t|
      if t
        f.puts t
      end
    end
  end
end

# A method to automatically create the .info file.
def createInfo
  info = $PRGNAM + ".info"
  infotext = [ "PRGNAM=\"#{$PRGNAM}\"",
               "VERSION=\"#{$VERSION}\"",
               "HOMEPAGE=\"#{$HOMEPAGE}\"",
               "DOWNLOAD=\"#{$DOWNLOAD}\"",
               "MD5SUM=\"#{%x{/usr/bin/md5sum #{$SRC} | cut -d \\  -f 1}.chomp}\"",
	       "DOWNLOAD_x86_64=\"\"",
	       "MD5SUM_x86_64=\"\"",
               "MAINTAINER=\"#{$AUTHOR}\"",
               "EMAIL=\"#{$EMAIL}\"",
               "APPROVED=\"\"" ]

  File.open info, "w" do |f|
    infotext.each do |t|
      f.puts t
    end
  end
end

# This creates a slack-desc.  You'll be wanting
# to edit it.  I promise.
def slackdesc
  File.open "slack-desc", "w" do |f|
    f.puts "# HOW TO EDIT THIS FILE:"
    f.puts "# The \"handy ruler\" below makes it easier to edit a package description.  Line"
    f.puts "# up the first \'|\' above the \':\' following the base package name, and the \'|\'"
    f.puts "# on the right side marks the last column you can put a character in.  You must"
    f.puts "# make exactly 11 lines for the formatting to be correct.  It's also"
    f.puts "# customary to leave one space after the \':\'."
    f.puts ""
    ($PRGNAM.length).times do f.write(" ") end 
    f.puts "|-----handy-ruler------------------------------------------------------|"
    f.puts "#{$PRGNAM}: #{$PRGNAM} (program that does something for linux)"
    f.puts "#{$PRGNAM}: "
    f.puts "#{$PRGNAM}: #{$PRGNAM} does something for Linux.  I'm not entirely sure what that"
    f.puts "#{$PRGNAM}: is, because at this point, the person using the sbsuite.rb script to"
    f.puts "#{$PRGNAM}: create me hasn't edited the slack-desc.  But that'll change soon,"
    f.puts "#{$PRGNAM}: right?"
    f.puts "#{$PRGNAM}: "
    f.puts "#{$PRGNAM}: ...right?"
    f.puts "#{$PRGNAM}: "
    f.puts "#{$PRGNAM}: Homepage: http://slaxer.com/sbsuite.php"
    f.puts "#{$PRGNAM}: "
  end
end

# A method to create a skeleton readme file.
# It's a good reminder to actually create one, anyway.
def readme
  File.open "README", "w" do |f|
    f.puts "It's customary, for SlackBuilds.org anyway, to include"
    f.puts "a README file describing the program/library/whatever."
    f.puts "Personally, I usually just grab the first paragraph off"
    f.puts "the homepage.  It's slick and easy."
    f.puts ""
    f.puts "This line usually includes any dependencies, notably"
    f.puts "those not included in Slackware, etc proper.  It's"
    f.puts "also nice to put some of the non-obvious stuff from"
    f.puts "the distro too sometimes."
  end
end

# I know, this is ugly. It also works just
# fine, and since I'm a slacker, this is
# what you get.
# By the way, say hi to the "main method."
if $*[0]
  if $*[1]
    if $*[2]
      if $*[3]
        if $*[4]
          $PRGNAM = $*[0]
          $VERSION = $*[1]
          $SRC = $*[2]
          $HOMEPAGE = $*[3]
          $DOWNLOAD = $*[4]
          makeBuild
          createInfo
          slackdesc
          readme
        else
          usage
        end
      else
        usage
      end
    else
      usage
    end
  else
    usage
  end
else
  usage
end

