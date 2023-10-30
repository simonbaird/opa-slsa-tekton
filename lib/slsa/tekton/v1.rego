# Rules for accessing details about Tekton tasks in a SLSA v1.0 format
# attestation predicate created by Tekton Chains
package slsa.tekton.v1

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# In SLSA v1.0 we extract details about the tasks from the resolvedDependencies list.
#
# An example of how they look:
# https://github.com/enterprise-contract/hacks/blob/main/provenance/recordings/05-SLSA-v1-0-tekton-build-type-Pipeline-in-cluster/decoded-content-att.json#L84
_raw_tasks(predicate) := _tasks if {
	# Sanity check the buildType value
	_build_type(predicate) == _expected_build_type

	# Use the resolvedDependencies list
	resolved_deps = predicate.buildDefinition.resolvedDependencies

	_tasks := {task |
		some resolved_dep in resolved_deps

		# There are other things in the resolvedDependencies list
		# so filter by name to pick out just the tasks
		resolved_dep.name == "pipelineTask"

		# Extract the task details from the encoded json content field
		task := json.unmarshal(base64.decode(resolved_dep.content))
	}
}

_expected_build_type := "https://tekton.dev/chains/v2/slsa-tekton"

# BuildType
_build_type(predicate) := predicate.buildDefinition.buildType

# Labels from the taskRun CR
_labels(raw_task) := raw_task.metadata.labels

# TaskRun results
_results(raw_task) := raw_task.status.taskResults

# The taskRef. In the data it could be missing so for consistency we'll
# use else to return an empty map object in that scenario
_ref(raw_task) := _r if {
	_r := raw_task.spec.taskRef
} else := {}

# TaskRun params
_params(raw_task) := raw_task.spec.params

# Assemble all the above useful pieces in an internal format that we can use
# in rules without caring about what the original SLSA format was.
_cooked_task(raw_task) := {
	"labels": _labels(raw_task),
	"results": _results(raw_task),
	"ref": _ref(raw_task),
	"params": _params(raw_task),
	# TODO: Other stuff here
}

tasks(predicate) := _tasks if {
	raw_tasks := _raw_tasks(predicate)
	_tasks := { cooked_task |
		some raw_task in raw_tasks
		cooked_task := _cooked_task(raw_task)
	}
}
