# ScriptAero
# CFD Queue Processor

An automated queue management system for CFD (Computational Fluid Dynamics) simulations. This script monitors a job queue and executes CFD simulations sequentially based on priority.

## Features

- **Priority-based execution**: Jobs are processed in order of priority (lower numbers = higher priority)
- **Automatic folder management**: Creates and manages queue, running, and completed job directories
- **Sequential processing**: Ensures only one simulation runs at a time to optimize resource usage
- **Error handling**: Automatically handles cases where simulation directories don't exist
- **Real-time monitoring**: Continuously monitors the queue for new jobs

## Directory Structure

The script automatically creates and manages the following directories:

```
project/
├── queue_processor.sh
├── queue/          # Pending jobs waiting to be executed
├── running/        # Currently executing job
└── done/           # Completed jobs (successful or failed)
```

## Job File Format

Each job file in the `queue/` directory must:
- Have a `.job` extension
- Contain exactly 4 lines with the following information:

```
[PRIORITY]
[CASE_DIRECTORY_NAME]
[COMMAND_TO_EXECUTE]
[DESCRIPTION]
```

### Job File Example

**File**: `queue/turbulent_flow.job`
```
1
airfoil_case
Allrun
Turbulent flow simulation around NACA 0012 airfoil
```

### Field Descriptions

| Field | Description | Example |
|-------|-------------|---------|
| **Priority** | Integer value (lower = higher priority) | `1`, `2`, `10` |
| **Case Directory** | Name of the CFD case folder (without path) | `airfoil_case` |
| **Command** | Script or command to execute | `Allrun`, `./run_simulation.sh` |
| **Description** | Human-readable description of the simulation | `"Turbulent flow analysis"` |

## Usage

### 1. Configuration

Before running the script, update the `CASES_DIR` variable in `queue_processor.sh` to point to your CFD cases directory:

```bash
# Edit this line in the script
CASES_DIR="/path/to/your/cfd/cases"
```

### 2. Create Job Files

Create `.job` files in the `queue/` directory following the format above.

### 3. Run the Queue Processor

Execute the script from the main directory:

```bash
./queue_processor.sh
```

The script will:
1. Create necessary directories if they don't exist
2. Monitor the `queue/` folder for new jobs
3. Execute jobs sequentially based on priority
4. Move completed jobs to the `done/` folder

## Example Workflow

1. **Create a job file**:
   ```bash
   echo -e "2\nmixer_case\nAllrun\nMixing tank simulation" > queue/mixer_simulation.job
   ```

2. **Start the queue processor**:
   ```bash
   ./queue_processor.sh
   ```

3. **Monitor progress**: Check the `running/` and `done/` directories to track job status.

## Error Handling

- If a case directory doesn't exist, the job is moved to `done/` with an `ERROR_` prefix
- Failed simulations are also moved to the `done/` directory for review
- Check the `done/` folder for any jobs that didn't complete successfully

## Advanced Usage

### Multiple Job Submission

Create multiple jobs with different priorities:

```bash
# High priority job
echo -e "1\ncritical_case\nAllrun\nUrgent simulation" > queue/urgent.job

# Medium priority job  
echo -e "5\nstandard_case\nAllrun\nStandard analysis" > queue/standard.job

# Low priority job
echo -e "10\ntest_case\nAllrun\nTest simulation" > queue/test.job
```

### Custom Commands

You can use any executable command or script:

```bash
echo -e "3\ncomplex_case\n./custom_solver.sh\nCustom solver execution" > queue/custom.job
```

## Notes

- **Single execution**: Only one job runs at a time to prevent resource conflicts
- **Continuous monitoring**: The script runs continuously until manually stopped
- **Case sensitivity**: Ensure case directory names match exactly
- **Permissions**: Make sure the script has execute permissions (`chmod +x queue_processor.sh`)

## Troubleshooting

### Common Issues

1. **Script won't start**: Check execute permissions
   ```bash
   chmod +x queue_processor.sh
   ```

2. **Jobs fail immediately**: Verify `CASES_DIR` path is correct

3. **Case not found errors**: Ensure case directory names in job files match actual directory names

4. **Jobs don't start**: Check job file format (must have exactly 4 lines)

### Stopping the Queue Processor

To stop the queue processor, use `Ctrl+C` in the terminal where it's running.

## Requirements

- Bash shell
- Read/write permissions in the working directory
- CFD simulation software (OpenFOAM, etc.) properly installed and configured