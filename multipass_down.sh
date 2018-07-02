#!/bin/bash

multipass stop $VM_NAME
multipass delete $VM_NAME
multipass purge

