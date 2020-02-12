# shellcheck shell=sh

Describe "repo-update"
	It "updates all the repositories when given no arguments"
		stderr() {
			%text:expand
			#|!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test'
			#|!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-libraries-only'
			#|!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-packages-only'
		}

		When call repo-update
		The status should eq 0
		The stderr should eq "$(stderr)"
	End

	It "updates only repositories given as arguments, if given any arguments"
		stderr() {
			%text:expand
			#|!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test'
			#|!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-libraries-only'
		}

		When call repo-update test test-libraries-only
		The status should eq 0
		The stderr should eq "$(stderr)"
	End

	It "will error out if you give it an unknown argument"
		When call repo-update -z
		The status should eq 1
		The lines of the entire stderr should eq 2
		The first line of stderr should eq '!! unknown argument -- z'
	End

	It "does not touch repositories when -d (dry run) is specified"
		Pending \
			"testdata repositories don't currently have any commands that would be ran for them anyhow"
	End

	It "shows any new changes since the last update a repository"
		Pending "not yet certain of the best way to test this"
	End
End