/*
 *
 * Copyright (c) 2016 Nest Labs, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#ifndef wpantund_wpanctl_cmds_h
#define wpantund_wpanctl_cmds_h

#include "tool-cmd-scan.h"
#include "tool-cmd-join.h"
#include "tool-cmd-form.h"
#include "tool-cmd-leave.h"
#include "tool-cmd-permit-join.h"
#include "tool-cmd-list.h"
#include "tool-cmd-status.h"
#include "tool-cmd-mfg.h"
#include "tool-cmd-resume.h"
#include "tool-cmd-reset.h"
#include "tool-cmd-begin-low-power.h"
#include "tool-cmd-begin-net-wake.h"
#include "tool-cmd-host-did-wake.h"
#include "tool-cmd-getprop.h"
#include "tool-cmd-setprop.h"
#include "tool-cmd-insertprop.h"
#include "tool-cmd-removeprop.h"
#include "tool-cmd-cd.h"
#include "tool-cmd-poll.h"
#include "tool-cmd-config-gateway.h"
#include "tool-cmd-add-prefix.h"
#include "tool-cmd-remove-prefix.h"
#include "tool-cmd-add-route.h"
#include "tool-cmd-remove-route.h"
#include "tool-cmd-peek.h"
#include "tool-cmd-poke.h"
#include "tool-cmd-pcap.h"
#include "tool-cmd-commr.h"
#include "tool-cmd-commissioner.h"
#include "tool-cmd-joiner.h"
#include "tool-cmd-dataset.h"
#include "tool-cmd-add-service.h"
#include "tool-cmd-remove-service.h"

#include "wpanctl-utils.h"

#define WPANCTL_CLI_COMMANDS \
	{ \
		"join", \
		"Join a WPAN.", \
		&tool_cmd_join, \
		0 \
	}, \
	{ "connect", "", &tool_cmd_join, 1 }, \
	{ \
		"form", \
		"Form a new WPAN.", \
		&tool_cmd_form, \
		0 \
	}, \
	{ \
		"attach", \
		"Attach/resume a previously commissioned network", \
		&tool_cmd_resume, \
		0 \
	}, \
	{ "resume", "", &tool_cmd_resume, 1 }, \
	{ \
		"reset", \
		"Reset the NCP", \
		&tool_cmd_reset, \
		0 \
	}, \
	{ \
		"begin-low-power", \
		"Enter low-power mode", \
		&tool_cmd_begin_low_power, \
		0 \
	}, \
	{ "lurk", "", &tool_cmd_begin_low_power, 1 }, \
	{ "wake", "", &tool_cmd_status, 1 }, \
	{ \
		"leave", \
		"Abandon the currently connected WPAN.", \
		&tool_cmd_leave, \
		0 \
	}, \
	{ "disconnect", "", &tool_cmd_leave, 1 }, \
	{ \
		"poll", \
		"Poll the parent immediately to see if there is IP traffic", \
		&tool_cmd_poll, \
		0 \
	}, \
	{ \
		"config-gateway", \
		"Configure gateway (deprecated, use `add-prefix` and `remove-prefix`)", \
		&tool_cmd_config_gateway, \
		0 \
	}, \
	{ \
		"add-prefix", \
		"Add prefix", \
		&tool_cmd_add_prefix, \
		0 \
	}, \
	{ \
		"remove-prefix", \
		"Remove prefix", \
		&tool_cmd_remove_prefix, \
		0 \
	}, \
	{ \
		"add-route", \
		"Add external route prefix", \
		&tool_cmd_add_route, \
		0 \
	}, \
	{ \
		"remove-route", \
		"Remove external route prefix", \
		&tool_cmd_remove_route, \
		0 \
	}, \
	{ \
		"add-service", \
		"Add service", \
		&tool_cmd_add_service, \
		0 \
	}, \
	{ \
		"remove-service", \
		"Remove service", \
		&tool_cmd_remove_service, \
		0 \
	}, \
	{ \
		"joiner", \
		"Joiner commands", \
		&tool_cmd_joiner, \
		0 \
	}, \
	{ \
		"commissioner", \
		"Commissioner commands", \
		&tool_cmd_commr, \
		0 \
	}, \
	{ "commr", "", &tool_cmd_commr , 1 }, \
	{ "o-commissioner", "", &tool_cmd_commissioner , 1 }, /* old commissioner command */ \
	{ "o-commr", "", &tool_cmd_commissioner , 1 }, \
	{ \
		"list", \
		"List available interfaces.", \
		&tool_cmd_list, \
		0 \
	}, \
	{ "ls", "", &tool_cmd_list, 1 }, \
	{ \
		"status", \
		"Retrieve the status of the interface.", \
		&tool_cmd_status, \
		0 \
	}, \
	{ \
		"permit-join", \
		"Permit other devices to join the current network.", \
		&tool_cmd_permit_join, \
		0 \
	}, \
	{ "pj", "", &tool_cmd_permit_join, 1 }, \
	{ "permit", "", &tool_cmd_permit_join, 1 }, \
	{ \
		"scan", \
		"Scan for nearby networks.", \
		&tool_cmd_scan, \
		0 \
	}, \
	{ \
		"mfg", \
		"Execute manufacturing command.", \
		&tool_cmd_mfg, \
		0 \
	}, \
	{ \
		"getprop", \
		"Get a property (alias: `get`).", \
		&tool_cmd_getprop, \
		0 \
	}, \
	{ "get", "", &tool_cmd_getprop, 1 }, \
	{ \
		"setprop", \
		"Set a property (alias: `set`).", \
		&tool_cmd_setprop, \
		0 \
	}, \
	{ "set", "", &tool_cmd_setprop, 1 }, \
	{ \
		"insertprop", \
		"Insert value in a list-oriented property (alias: `insert`, `add`).", \
		&tool_cmd_insertprop, \
		0 \
	}, \
	{ "insert", "", &tool_cmd_insertprop, 1 }, \
	{ "add", "", &tool_cmd_insertprop, 1 }, \
	{ \
		"removeprop", \
		"Remove value from a list-oriented property (alias: `remove`).", \
		&tool_cmd_removeprop, \
		0 \
	}, \
	{ "remove", "", &tool_cmd_removeprop, 1 }, \
	{ \
		"begin-net-wake", \
		"Initiate a network wakeup", \
		&tool_cmd_begin_net_wake, \
		0 \
	}, \
	{ \
		"host-did-wake", \
		"Perform any host-wakeup related tasks", \
		&tool_cmd_host_did_wake, \
		0 \
	}, \
	{ \
		"pcap", \
		"Start a packet capture", \
		&tool_cmd_pcap, \
		0 \
	}, \
	{ \
		"peek", \
		"Peek into NCP memory", \
		&tool_cmd_peek, \
		0 \
	}, \
	{ \
		"poke", \
		"Poke NCP memory (change content at a NCP memory address)", \
		&tool_cmd_poke, \
		0 \
	}, \
	{ \
		"dataset", \
		"Issue commands related to the local dataset", \
		&tool_cmd_dataset, \
		0 \
	}, \
	{ \
		"cd", \
		"Change current interface (command mode)", \
		&tool_cmd_cd, \
		0 \
	}

#endif
