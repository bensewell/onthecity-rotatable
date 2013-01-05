# Perl script for retrieving a rota from The City in tabular form

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Request::Common qw(GET);
use HTTP::Cookies;
use Crypt::SSLeay;
use Data::Dumper;

#create and set up the user agent.
my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/8.0');
$ua->cookie_jar( HTTP::Cookies->new( file => 'cookies.txt', autosave => 1));

#log in
login($ua, my $success);

exit 0;



# sub login ($ua, $success)
#
# parameters:
#     $ua      -  in: LWP user agent to use
#     $success - out: Boolean to report success
#
sub login
{
   my $ua = $_[0];
   my $login_name;
   my $login_password;
   my $req;
   my $res;
   my $success = 0;

   print "Enter login name:";
   $login_name = <STDIN>;
   chomp($login_name);
   print "Enter login password:";
   $login_password = <STDIN>;
   chomp($login_password);

   #first get the login page
   $req = GET('https://gracetruro.onthecity.org/session/new');
   $res = $ua->request($req);
   if(!$res->is_success)
   {
      die "Unable to get login page";
   }

   #now parse for the authenticity token
   open(my $lfh, '>', 'login_response.txt') or die "Cannot open log file for login response";
   print $lfh Dumper($res->content);
   close($lfh);
   $res->content #TODO: regular expression match for authenticity token


   $req = POST('https://gracetruro.onthecity.org',
              [ login=>$login_name, 
                password=>$login_password, 
                invitation_code=>0, 
                remember_me=>"no" 
              ]
              );

   $res = $ua->request($req);

   if($res->code == 302)
   {
      print "Redirecting to:\n";
      print Dumper($res->headers);
      die;
   }

   if($res->is_success)
   {
      my $fh;
      my $filename = 'result.html';
      print "Successfully retrieved login page. Writing to '$filename'.\n";
      open($fh, '>', $filename) or die "Could not open '$filename'";
      print $fh $res->content;
      close $fh;
      $success = 1;
   }
   else
   {
      print "Unsuccessful request\n";
      print $res->status_line . "\n";
   }

   # return success
   $_[1] = $success;
}
