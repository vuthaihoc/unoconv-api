FROM golang:1.11 as api-builder
WORKDIR /unoconv-api
COPY . /unoconv-api
RUN go build


FROM ubuntu:bionic

LABEL maintainer="kaufmann.r@gmail.com"

COPY --from=api-builder /unoconv-api/unoconv-api /opt/unoconv-api/unoconv-api

#Install unoconv
RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive \
	    apt-get upgrade -y && \
		apt-get install -y \
		        locales \
			unoconv \
			supervisor \
            fonts-dejavu fonts-lato fonts-lmodern ttf-dejavu ttf-unifont ttf-freefont ttf-liberation \
            && \
        apt-get remove -y && \
	    apt-get autoremove -y && \
        apt-get clean && \
			rm -rf /var/lib/apt/lists/

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:de  
ENV LC_ALL en_US.UTF-8  

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./fonts/* /usr/share/fonts/
RUN fc-cache -fv && fc-list

# Expose 3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl http://localhost:3000/unoconv/health

# Startup
ENTRYPOINT ["/usr/bin/supervisord"]
