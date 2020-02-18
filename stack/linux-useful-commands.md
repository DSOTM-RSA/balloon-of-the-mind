# Useful Linux Commands

**Rerun command as root**

	sudo !!
	
**Open editor**

	crtl + x + e
	
**Create a fast RAM disk**

	mkdir -p /mnt/ram
	mount - tmpfs tmpfs /mnt/ram -o size = 4096M
	dd if=/dev/zero of=test.iso bs=1M count = 1000
	
**Run a command that shouldn't be in the history**

	ls -l 
	
**Fix a long command**

	fc 
	
**Creating tunnels with SSH**

	ssh -L 3387:[xxx.x.x.x:port] root@ip -N
	
	crtl+z
	bg
	
**Quickly create folders**

	mkdir -p folder/{sub1,sub2}/{1..10}
	
**Intercept stdout**

	cat file | tee -a log | cat > dev/null
	
	cat log
	
**Exit terminal leaving all processes running**

	sleep 123
	crtl+z
	
	disown -a && exit
	
	ps aux | grep sleep

