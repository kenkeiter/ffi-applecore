/*
 *  applecore.c
 *  applecore
 *
 *  Created by Kenneth Keiter on 11/27/10.
 *  Copyright 2010 Relevance, Inc. All rights reserved.
 *
 */

#include <stdlib.h>
#include <errno.h>
#include <syslog.h>
#include <asl.h>
#include <launch.h>

#include "applecore.h"

int kq; // kernel queue

asl_context *asl_create_context(char *name, char *facility, uint32_t opts){
	int retval = EXIT_SUCCESS;
	asl_context *ctx = (asl_context *) malloc(sizeof(asl_context));
	if(ctx->client == NULL){
		retval = EXIT_FAILURE;
	}
	ctx->client = asl_open(name, facility, opts);
	ctx->logmsg = asl_new(ASL_TYPE_MSG);
	asl_set(ctx->logmsg, ASL_KEY_SENDER, name);
	return ctx;
};

int asl_finalize_context(asl_context *ctx){
	int retval = EXIT_SUCCESS;
	if(ctx->client){ 
		asl_close(ctx->client);
	}else{
		retval = EXIT_FAILURE;
	}
	free(ctx);
	return retval;
};

int asl_log_event(asl_context *ctx, uint8_t sev, char *msg){
	int retval = EXIT_SUCCESS;
	if(ctx->client){
		asl_log(ctx->client, ctx->logmsg, sev, msg);
	}else{
		retval = EXIT_FAILURE;
	}
	return retval;
};

int asl_add_output_file(asl_context *ctx, int fp){
	return asl_add_log_file(ctx->client, fp);
};
	   
int asl_remove_output_file(asl_context *ctx, int fp){
	return asl_remove_log_file(ctx->client, fp);
};
	   
int launchd_register(){
	int retval = EXIT_SUCCESS;
	launch_data_t checkin_request;
	launch_data_t checkin_response;
	
	if((checkin_request = launch_data_new_string(LAUNCH_KEY_CHECKIN)) == NULL){
		retval = EXIT_FAILURE;
		goto done;
	}
	
	if((checkin_response = launch_msg(checkin_request)) == NULL){
		retval = EXIT_FAILURE; // IPC failure.
		goto done;
	}
	
	if(launch_data_get_type(checkin_response) == LAUNCH_DATA_ERRNO){
		errno = launch_data_get_errno(checkin_response);
		retval = errno;
		goto done;
	}
	
done:
	launch_data_free(checkin_response);
	return retval;
};

