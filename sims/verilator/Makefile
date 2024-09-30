#########################################################################################
# verilator makefile
#########################################################################################

ifeq ($(shell which verilator),)
  $(error Did not find Verilator in PATH. Make sure all requirements are installed)
endif

#########################################################################################
# general path variables
#########################################################################################

base_dir=$(abspath ../..)
sim_dir=$(abspath .)

#########################################################################################
# include shared variables
#########################################################################################

# include $(base_dir)/variables.mk
MODEL_PACKAGE=chipyard.harness
CONFIG=Rocket64x1

#########################################################################################
# name of simulator (used to generate *.f arguments file)
#########################################################################################

sim_name = verilator

#########################################################################################
# verilator simulator types and rules
#########################################################################################

sim_prefix = simulator
sim = $(sim_dir)/$(sim_prefix)-$(MODEL_PACKAGE)-$(CONFIG)
sim_debug = $(sim_dir)/$(sim_prefix)-$(MODEL_PACKAGE)-$(CONFIG)-debug

include $(base_dir)/sims/common-sim-flags.mk

# If verilator seed unspecified, verilator uses srand as random seed
ifdef RANDOM_SEED
SEED_FLAG=+verilator+seed+$(RANDOM_SEED)
else
SEED_FLAG=
endif

.PHONY: default debug
default: $(sim)
debug: $(sim_debug)cd 

