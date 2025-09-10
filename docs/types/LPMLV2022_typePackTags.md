# LPMLV2022_typePackTags

## Description

Main PackTags structure according to OMAC PackML V2022 standard. This type contains the complete interface structure for machine communication, including command tags for controlling the machine, status tags for monitoring operation, and administration tags for quality and alarm information.

## Structure

| Field | Type | Description |
|-------|------|-------------|
| `Command` | `LPMLV2022_typeCommand` | Command tags are used to control the operation of the unit/machine. Command tags include unit state commands which control the state transitions in the base state model. The command tags also include parameters and process variables which control how the machine operates |
| `Status` | `LPMLV2022_typeStatus` | Status tags are used to describe the operation of the unit/machine. Status tags include state commands which describe the state transitions in the base state model. The status tags also include parameters and process variables which describe how the machine operates |
| `Admin` | `LPMLV2022_typeAdmin` | Administration tags are used to describe the quality and alarm information of the unit/machine. Administration tags include alarm parameters which describe the conditions within the base state model typically for production data acquisition (PDA) systems. The administration tags also include parameters which can describe how well the machine operates, or specific information on the product quality produced by the machine |

## Usage

This type represents the complete PackML interface structure for machine communication. It provides standardized variable structures (pack tags) for cross-machine coupling between machine controllers and to higher-level HMI, MES or Enterprise systems according to ISA Technical Report TR88.00.02 Machine and Unit States.
