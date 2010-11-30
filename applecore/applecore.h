/*
 *  applecore.h
 *  applecore
 *
 *  Created by Kenneth Keiter on 11/27/10.
 *  Copyright 2010 Relevance, Inc. All rights reserved.
 *
 */

#include <sys/types.h>
#include <sys/event.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <syslog.h>
#include <asl.h>
#include <libgen.h>
#include <launch.h>

typedef struct {
	aslclient client;
	aslmsg logmsg;
} asl_context;

asl_context *asl_create_context(char *name, char *facility, uint32_t opts);
int asl_finalize_context(asl_context *ctx);
int asl_log_event(asl_context *ctx, uint8_t sev, char *msg);
int asl_add_output_file(asl_context *ctx, int fp);
int asl_remove_output_file(asl_context *ctx, int fp);

int launchd_register();

