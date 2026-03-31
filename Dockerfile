FROM perl:latest

# Install necessary system dependencies for Net::Twitter
RUN apt-get update && apt-get install -y \
    libnet-ssleay-perl \
    libauthen-sasl-perl \
    libcrypt-ssleay-perl \
    && rm -rf /var/lib/apt/lists/*

# Install required Perl modules
RUN cpan install Net::Twitter

# Create data directory for storing output
RUN mkdir -p /data

# Copy the script
COPY One.pl /usr/local/bin/twitter-trawler.pl
RUN chmod +x /usr/local/bin/twitter-trawler.pl

# Set working directory
WORKDIR /data

# Entry point
ENTRYPOINT ["perl", "/usr/local/bin/twitter-trawler.pl"]