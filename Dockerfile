FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y vim cron sudo gcc

# Add low-privileged users
RUN useradd -m -s /bin/bash -u 1000 jerry
RUN useradd -m -s /bin/bash -u 1001 tom

# Change the password for user tom
RUN echo "tom:#djoiu{ef&lmae!!" | chpasswd 
RUN echo "#djoiu{ef&lmae!!" > /home/tom/.passwd && chmod 750 /home/tom

# Use the same password for root ( Credential reuse vuln for privesc )
RUN echo "root:#djoiu{ef&lmae!!" | chpasswd 

# Copy the crontab file and the script
COPY ./crontab /etc/cron.d/mycron
COPY exploit_me.sh /usr/bin/exploit_me.sh

# SUID vulnerability
RUN chown tom:tom /usr/bin/find && \
    chmod 4755 /usr/bin/find

# Crontab vulnerability
RUN chmod 746 /usr/bin/exploit_me.sh && \
    chmod 0644 /etc/cron.d/mycron

# Set up sudo for user "tom"
RUN mkdir -p /etc/sudoers.d && \
    echo "tom ALL=(ALL) NOPASSWD: /usr/bin/vim" > /etc/sudoers.d/tom

COPY ./entrypoint.sh /.entrypoint.sh
RUN chmod +x /.entrypoint.sh

CMD ["/.entrypoint.sh"]
