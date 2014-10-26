######################################################################
# Test suite for Net::SSH::AuthorizedKeysFile
# by Mike Schilli <m@perlmeister.com>
######################################################################

use warnings;
use strict;
use Sysadm::Install qw(:all);
use File::Temp qw(tempfile);

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);

use Test::More tests => 11;
BEGIN { use_ok('Net::SSH::AuthorizedKeysFile') };

my $tdir = "t";
$tdir = "../t" unless -d $tdir;
my $cdir = "$tdir/canned";

use Net::SSH::AuthorizedKeysFile;

my $ak = Net::SSH::AuthorizedKeysFile->new(file => "$cdir/ak.txt");

my @keys = $ak->keys();

is($keys[0]->keylen(), 1024, "keylen");
is($keys[1]->keylen(), 1024, "keylen");
is($keys[1]->exponent(), 35, "exponent");
is($keys[0]->email(), 'quack@schmack.com', "email");
is($keys[1]->email(), 'quack2@schmack.com', "email");

like($keys[0]->key(), qr/^1\d+$/, "key");
like($keys[1]->key(), qr/^2\d+$/, "key");

my($fh, $filename) = tempfile();

    # Modify a authkey file
cp "$cdir/ak.txt", $filename;
my $ak2 = Net::SSH::AuthorizedKeysFile->new(file => $filename);
@keys = $ak2->keys();

$keys[0]->keylen(1025);
$keys[1]->option("From", 'hugo@hugo.com');
$ak2->save();

    # Read in modifications
my $ak3 = Net::SSH::AuthorizedKeysFile->new(file => $filename);
@keys = $ak3->keys();

is($keys[0]->keylen(), 1025, "modified keylen");
is($keys[1]->option("From"), 'hugo@hugo.com', "modified from=");

    # Remove option
$keys[1]->option_delete("From");
$ak3->save();

my $ak4 = Net::SSH::AuthorizedKeysFile->new(file => $filename);
@keys = $ak4->keys();

is($keys[1]->option("From"), undef, "Removed from");
#print $ak4->as_string();
