#!/bin/perl5

# price2.pl - Calculates from pricing form

# London rate of 195 per day + 14 per day per person INCLUDING Tutor

$fixed = 500;
$each = 75;
$night = 90;
$mile = 0.45;
$london = 209;
$harwell = 200;
$hmeal = 7;
$lmeal = 14;
$VAT = 17.5;
$condit = "*Price for courses completed by 31st December 2001";

# ********** Get the input ********

read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# ******* Go generate the echo page

open (SEGMENT,"price.start");
while ($line = <SEGMENT> ) {
        print $line;}
print "<HR>";

# **** Get form contents and environment, and log them

# Split the name-value pairs
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
{
    ($name, $value) = split(/=/, $pair);
    # Un-Webify plus signs and %-encoding
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $user_input{$name} = $value;
}

$email = $user_input{"email"};
$person = $user_input{"person"};
$person = $user_input{"person"};
$organisation = $user_input{"organisation"};
$address = $user_input{"address"};
$name = $user_input{"name"};
$length = $user_input{"length"};
$number = $user_input{"number"};
$where = $user_input{"where"};
$distance = $user_input{"distance"};

$number =~ tr/0-9//cd ;
$length =~ tr/0-9//cd ;
$distance =~ tr/0-9//cd ;
$email =~ s/\s//g;
$address =~ tr/'`"/   /;  # sanitise!

unless ($email =~ /[-.0-9a-z_]+@[-0-9a-z_]+(\.[-0-9a-z_])+/i){
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please specify a valid email address. $email </B><BR>
We won't be able to email you an official price quotation without it.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
}

unless (length ($number)) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please enter the number of students. $number </B><BR>
We need to know how many people are to be trained before we can give
you a quotation.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
} else {
if ($number < 1 || $number > 12) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please enter a number of students between 1 and 12.</B><BR>
We usually limit our class sizes to 10 students, but on a few
courses we will take up to 12.  If you have more than 10 trainees,
please call us, and/or consider running several courses.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
}}

unless (length ($length)) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please enter at least one digit for the duration. $length </B><BR>
We need to know how long the course will be before we can give
you a quotation.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
} else {
if ($length < 1 || $length > 5) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Courses must be 1 to 5 days in length.</B><BR>
For courses that run longer than one week, please call for multiple quotations - e.g.
if you want 7 days of training (4 days one week, and 3 another
week) please call up two separate quotes, one for 4 days then another for 3 days.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
}}

if ($where == 2 && ! length ($distance)) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please enter a distance for an on site course.</B><BR>
We will need to know how far our tutor must travel and whether
he'll need to stay overnight in an accommodation.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
} else {
if ($distance < 0 || $distance > 650) {
print <<NONUM ;
<FONT COLOR="#FF4446">ERROR</FONT><BR>
<B>Please enter another distance.</B><BR>
Distance must be in range of 0 to 650 miles.  We are very
happy to quote for courses in Europe and the USA; please
contact us for a special quotation.
<HR SIZE=1 NOSHADE>
NONUM
$oops++;
}}


$daily = $number * $each + $fixed;
$fees = $daily * $length;

if ($where == 2) {
$mileage = $mile * $distance * 2;
$nnights = ($distance > 50) * ($length - ($distance < 100) + ($distance > 150) ) ;
$accom = $nnights * $night;
$expenses = $accom + $mileage;
} else {
$dayroom = ($where == 0)?$london:$harwell;
$meal = ($where == 0)?$lmeal:$hmeal;
$allroom = $length * $dayroom;
$food = $length*$number*$meal;
$expenses = $allroom+$food;
}

$overall=$fees+$expenses;
$date = `date`;

$tax = $VAT * $overall / 100.0;
$grand = $overall+$tax;

$locator = ("our London training centre",
	"our Harwell training centre","your own site, approximately")[$where];
$dis = ($where<2)?"":($distance." miles from our Harwell centre");

$quoteno = time();

unless ($oops) {

########################################################

$daily=mpform($daily);
$fees=mpform($fees);
$mile=mpform($mile);
$mileage=mpform($mileage);
$night=mpform($night);
$accom=mpform($accom);
$dayroom=mpform($dayroom);
$allroom=mpform($allroom);
$meal=mpform($meal);
$food=mpform($food);
$overall=mpform($overall);
$tax=mpform($tax);
$grand=mpform($grand);

$mailprog = '/usr/lib/sendmail';
$recipient = $email;

foreach $recipient($email,'mick@firstalt.co.uk','pauline@firstalt.co.uk'){
open (MAIL, "|$mailprog $recipient");
# open (MAIL, ">/tmp/try");
print MAIL 'From: mick@firstalt.co.uk (First Alternative)',"\n";
print MAIL 'Reply-to: mick@firstalt.co.uk (First Alternative)',"\n";
print MAIL 'Subject: Quotation for training',"\n\n";

print MAIL << "MAILIT";

Quotation for On-site training from First Alternative.

This quotation has been generated via the automated quotation
system at First Alternative's web site.  

Whilst every effort has been made to ensure these numbers are 
accurate, we do not propose these rates to be anything other 
than an initial estimate; nor can we ensure course availability. 
Please phone us on (01235) 820011 or email mick\@firstalt.co.uk 
to discuss pricing and scheduling if these specifications meet with
your requirements.

To:

$person
$organisation
$address

$date
Quotation Number: $quoteno

$name
A $length day course for $number student(s)

Course to be held at $locator $dis

Daily course fee $daily for $length days = $fees 

MAILIT

print MAIL <<"MBOD2" if ($where == 2);
Tutor's mileage $distance x 2 at $mile per mile = $mileage 
Overnight hotel for $nnights nights at $night per night = $accom 
MBOD2

print MAIL <<"MBOD3" if ($where != 2);
Charge for training room - $dayroom per day = $allroom
Lunches for $length days for $number students at $meal = $food
MBOD3

print MAIL <<"MBOD4" ;
Total cost (before VAT) = $overall
 
VAT at $VAT% = $tax
 
Grand Total of $grand*

MBOD4
 
print MAIL $condit,"\n";
print MAIL "All prices quoted are in pounds sterling\nE&OE\n";

# send environment to Pauline and Mick
if ($nbv++) {
foreach (keys %ENV) {
print MAIL ;
print MAIL "   ",$ENV{$_},"\n";
}
}
close MAIL;

}
#####################################################################

$daily=poundform($daily);
$fees=poundform($fees);
$mile=poundform($mile);
$mileage=poundform($mileage);
$night=poundform($night);
$accom=poundform($accom);
$dayroom=poundform($dayroom);
$allroom=poundform($allroom);
$meal=poundform($meal);
$food=poundform($food);
$overall=poundform($overall);
$tax=poundform($tax);
$grand=poundform($grand);

$address =~ s/\n/<BR>/g;

print <<"BODY" ;
<H2>Quotation for Custom Onsite Course</H2>
This proposal was electronically generated by First Alternative
through our website at http://www.firstalt.co.uk with a copy emailed to $email. Whilst every effort has
been made to ensure these numbers are accurate, we do not propose
these rates to be anything other than an initial estimate; nor can we
ensure course availability. Please phone us on (01235) 820011
or email mick&#064firstalt.co.uk to discuss pricing and placement if these specifications meet with
your requirements.
<HR SIZE=1 NOSHADE>
<IMG SRC=http://www.firstalt.co.uk/img/firstaltlogo.gif ALIGN=LEFT> 

<TABLE>
<TR>
<TD ALIGN=RIGHT>
<FONT FACE=Helvetica, Ariel><B><FONT SIZE=2>To:</FONT></B>
</TD>
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$person
</TD>
</TR>

<TR>
<TD ALIGN=RIGHT> 
<FONT FACE=Helvetica, Ariel><B><FONT SIZE=2>email:</FONT></B>
</TD>
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$email
</TD>
</TR>

<TR>
<TD ALIGN=RIGHT> 
<FONT FACE=Helvetica, Ariel><B><FONT SIZE=2>Company:</FONT></B>
</TD>
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$organisation
</TD>
</TR>

<TR>
<TD ALIGN=RIGHT> 
<FONT FACE=Helvetica, Ariel><B></B>
</TD>
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT VALIGN=TOP>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$address
</TD>
</TR>
 
<TR>
<TD ALIGN=RIGHT> 
<FONT FACE=Helvetica, Ariel><B><FONT SIZE=2>Date:</FONT></B>
</TD>    
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$date
</TD>
</TR>


<TR>
<TD ALIGN=RIGHT>
<FONT FACE=Helvetica, Ariel><B><FONT SIZE=2>Quote ref:</FONT></B>
</TD> 
<TD ALIGN=LEFT></TD>
<TD ALIGN=LEFT VALIGN=TOP>
<FONT FACE=Helvetica, Ariel><FONT SIZE=2>$quoteno
</TD> 
</TR>

</TABLE>
<BR CLEAR=ALL>
<HR SIZE=1 NOSHADE>
<CENTER><I>1 The Court, High Street, Harwell, Oxfordshire OX11 0EY 
<BR>
Fax: (01235) 820750</I></CENTER>
<HR SIZE=1 NOSHADE>

Dear $person:
<P>
We are pleased to offer the following quotation as per your request:<P>

<FONT COLOR="#FF4446">COURSE</FONT></BR>
$name<BR>
A $length day course for $number student(s)
<P>
<FONT COLOR="#FF4446">VENUE</FONT></BR>
Course to be held at $locator $dis
<P>
<FONT COLOR="#FF4446">PRICE</FONT></BR>
<LI>Daily course fee $daily for $length days = $fees <BR>
BODY

print <<"BOD2" if ($where == 2);
<LI>Tutor's mileage $distance x 2 at $mile per mile = $mileage <BR>
<LI>Overnight hotel for $nnights nights at $night per night = $accom <BR>
BOD2

print <<"BOD3" if ($where != 2);
<LI>Charge for training room - $dayroom per day = $allroom<BR>
<LI>Lunches for $length days for $number students at $meal = $food<BR>
BOD3

print <<"BOD4" ;
<LI>Total cost (before VAT) = $overall<BR>

<LI>VAT at $VAT% = $tax<BR>

<H4>Grand Total of $grand*</H4><P>

Quotation dated $date.<BR> E & O E.<P>
BOD4

print $condit;


} else {

print "Press the BACK button to return to your form to correct any 
errors, then resubmit. Thank you.";
}

open (SEGMENT,"price.end");
while ($line = <SEGMENT> ) {
        print $line;}

sub poundform {
sprintf("&#163;%.2f",$_[0]);
}
sub mpform {
sprintf("%.2f",$_[0]);
}
