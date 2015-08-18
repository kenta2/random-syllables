#! /usr/bin/perl -w

# Copyright 2012 Ken Takusagawa

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$iter=2;
$lines=1;
$onlyspace=0;
$digraph=1;
$syllables=1;
open RAND,"/dev/urandom" or die;

@letters=("a".."z");
# is T reachable because of the angled rows?
#@letters=&subtract(\@letters,['t']);
#@letters=&subtract(\@letters,['y','g','h','b','n']);
@letters=&subtract(\@letters,['y','b']); #long reach
#print @letters;
@vowels=qw/a e i o u/;
@consonant1=&subtract(\@letters,\@vowels);
@consonants=&subtract(\@consonant1,['q']);

push @consonants,"" if $digraph; #non-three-letter words

push @consonants,('th','ch','sh','ph') if $digraph; #ph

@initials=&subtract(\@consonants,['x']);
@tails=&subtract(\@consonants,['y','h','w']);
push @initials,qw(wh pr st fr tr cl sp pl sc gr kn cr fl sm) if $digraph;
push @tails,('ng','nd','ll','st','nt','ts','ld','ns','ss','nk','ck','ds','gh') if $digraph;

#easily reachable punctuation on a US Keyboard
@punctuation=(' ', ';',',','.','/','\'');

push @punctuation,(':','<','>','?','"'); #shifted
#shift OK because left shift is fairly easy to reach

@punctuation=(' ') if $onlyspace;


#&lengthprint(@initials);
#&lengthprint(@vowels);
#&lengthprint(@tails);
#&lengthprint(@punctuation);
$entropy=0;
$entropy+=log(scalar(@initials));
$entropy+=log(scalar(@vowels));
$entropy+=log(scalar(@tails));
$entropy+=log(scalar(@punctuation));
$entropy/=log(2);
#print STDERR scalar@initials,"*",scalar@vowels,"*",scalar@tails,"*",scalar@punctuation," = $entropy bits \n";
for(1..$lines){ #num lines
    for(1..$iter){
        for(1..$syllables){
            #numsyllables.  1 syllable found better than 2 syllables.
            #average syllable length 10760/3080
            #versus 11 punctuation
            print
                &select_random(@initials),
                &select_random(@vowels),
                &select_random(@tails);
        }
        print &select_random(@punctuation);
    }
    print "\n";
}
sub lengthprint {
    print scalar@_;
    print " ",@_,"\n";
}
sub subtract {
    my $a=shift;
    my $b=shift;
    my $left;
    my $right;
    my @result;
    for$left(@$a){
        my $ok=1;
        for$right(@$b){
            if($left eq $right){
                $ok=0;
                last;
            }
        }
        if ($ok){
            push @result,$left;
        }
    }
    @result;
}
sub printrefs{        

    my $a=shift;
    my $b=shift;
    print @$a,"\n\n";
    print @$b,"\n";
}
sub getrand_maybe{
    my $target=shift;
    my $sample=shift;
    my $m=$sample % $target;
    my $over1 = $target + ($sample - $m);
    if ($over1<=256){
        $m;
    }else{
        -1;
    }
}
    
sub getrand_test{
    my $target=shift;
    my $sample;
    my @output;
    for$sample(0..255){
        push @output,&getrand_maybe($target,$sample);
    }
    @output;
}

sub getrand{
    my$target=shift;
    my$answer;
    for(;;){
        my$sample=getc RAND;
        $sample=ord$sample;
        $answer=&getrand_maybe($target,$sample);
        last if $answer>=0;
    }
    $answer;
}
sub select_random{
    $_[&getrand(scalar@_)];
}
