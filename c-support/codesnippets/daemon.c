/*
 * =============================================================================
 *
 *       Filename:  daemon.c
 *
 *    Description:  Daemon Function
 *
 *        Version:  1.0
 *        Created:  11/14/13 07:22
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Lei Liu (ShadowStar), liulei@jusontech.com
 *   Organization:  Juson Tech
 *
 * =============================================================================
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>

void __init_daemon(void)
{
	switch (fork()) {
	case -1:
		exit(EXIT_FAILURE);
	case 0:
		if (setsid() < 0)
			exit(EXIT_FAILURE);
		umask(0);
		close(STDIN_FILENO);
		close(STDOUT_FILENO);
		close(STDERR_FILENO);
		break;
	default:
		exit(EXIT_SUCCESS);
	}
}

