.PHONY: alu regfile clean status

alu:
	./scripts/run_alu_tb.sh

regfile:
	./scripts/run_regfile_tb.sh

clean:
	rm -rf build
	rm -f sim/wave/*.vcd
	rm -f sim/wave/*.fst
	rm -f sim/log/*.log

status:
	git status
