# Add a command to add tweet to pinboard for storage or later
# viewing from GUI browser

# The file ~/.pinboard should be one line in the format username:PINBOARD_API_KEY
#
use URI::Escape;


$addaction = sub {
    my $command = shift;

    if ($command =~ m#^/pin ([^ ]+)?#) {
        my $tweet_id=$1;
        my $tweet=&get_tweet($tweet_id);
        my $content;
        if (!$tweet->{'id_str'}) {
            print $stdout "-- sorry, no such tweet (yet?).\n";
            return 1;
        }
        chop( my $pin_pass=`cat ~/.pinboard`);

		my $tweet_text = $tweet->{'text'};
		$safe_text = uri_escape($tweet_text);
		#print "SAFE: ". $safe_text ."\n";
        my $add_url="https://twitter.com/$tweet->{'user'}->{'screen_name'}/statuses/$tweet->{'id_str'}";
        my $pinboard_url="https://api.pinboard.in/v1/posts/add?url=" .
            $add_url . "&tags=ttytter_added&shared=no&toread=yes&description=$safe_text" 
			. "&auth_token=" . $pin_pass;

            $content = `curl -s \"$pinboard_url\"`;

        if ($content =~ m!<result code="done" />!){
            print "Added to Pinboard\n";
        }else{ 
            print "Something went wrong, not added. See response:\n" if $content;
            print $content;
            print "Something went wrong, probably because of an SSL problem.\n" if not $content;
        }
        return 1;
    }
    return 0;
};

