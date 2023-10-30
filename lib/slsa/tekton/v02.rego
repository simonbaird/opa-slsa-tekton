# Rules for accessing details about Tekton tasks in a SLSA v0.2 format
# attestation predicate created by Tekton Chains
package slsa.tekton.v02

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# In SLSA v0.2 the tasks are accessible in buildConfig.tasks.
#
# An example of how they look:
# https://github.com/enterprise-contract/hacks/blob/main/provenance/recordings/01-SLSA-v0-2-Pipeline-in-cluster/attestation.json#L35
_raw_tasks(predicate) := _tasks if {
	# Sanity check the buildType value
	_build_type(predicate) == _expected_build_type

	# Return the list of tasks
	_tasks := predicate.buildConfig.tasks
}

_expected_build_type := "tekton.dev/v1beta1/PipelineRun"

# BuildType
_build_type(predicate) := predicate.buildType

# Labels from the taskRun CR
_labels(raw_task) := raw_task.invocation.environment.labels

# The taskRun results
_results(raw_task) := raw_task.results

# The taskRef. Could be an empty map object.
_ref(raw_task) := raw_task.ref

# Assemble all the above useful pieces in an internal format that we can use
# in rules without caring about what the original SLSA format was.
_cooked_task(raw_task) := {
	"labels": _labels(raw_task),
	"results": _results(raw_task),
	"ref": _ref(raw_task),
	# TODO: Other stuff here
}

tasks(predicate) := _tasks if {
	raw_tasks := _raw_tasks(predicate)
	_tasks := { cooked_task |
		some raw_task in raw_tasks
		cooked_task := _cooked_task(raw_task)
	}
}