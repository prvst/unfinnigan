# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Finnigan.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
BEGIN { use_ok('Finnigan') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $file = "t/100225.raw";
open INPUT, "<$file" or die "can't open '$file': $!";
binmode INPUT;
my $header = Finnigan::FileHeader->decode(\*INPUT);
is( $header->size, 1356, "FileHeader->size" );
is( $header->audit_start->time, "2010-02-25 09:02:27", "AuditTag->time" );

my $seq_row = Finnigan::SeqRow->decode(\*INPUT, $header->version);
is( $seq_row->size, 260, "SeqRow->size" );
is( $seq_row->file_name, 'C:\Xcalibur\calsolution\100225.raw', "SeqRow->file_name" );
is( $seq_row->injection->size, 64, "InjectionData->size" );
is( $seq_row->injection->n, 1, "InjectionData->n" );

my $cas_info = Finnigan::CASInfo->decode(\*INPUT);
is( $cas_info->size, 28, "CasInfo->size" );
is( $cas_info->preamble->size, 24, "CasInfoPreamble->size" );

my $rfi = Finnigan::RawFileInfo->decode(\*INPUT, $header->version);
is( $rfi->size, 844, "RawFileInfo->size" );
is( $rfi->preamble->size, 804, "RawFileInfoPreamble->size" );
is( $rfi->preamble->run_header_addr, 777542, "RawFileInfoPreamble->run_header_addr" );

my $mf = Finnigan::MethodFile->decode(\*INPUT);
is( $mf->size, 3646, "MethodFile->size" );
is( $mf->file_size, 20992, "MethodFile->file_size" );
is( $mf->container->find("LTQ/Text")->name, "Text", "OLE2DirectoryEntry->find" );
is( length $mf->container->find("LTQ/Text")->data, 9722, "OLE2DirectoryEntry->data" );
