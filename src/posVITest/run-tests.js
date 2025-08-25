import { execSync } from 'child_process';

console.log('Running all Vitest tests...\n');

try {
  const result = execSync('npm test', {
    encoding: 'utf8',
    stdio: 'pipe',
  })
  console.log(result)
} catch (error) {
  console.log(error)
  console.log('Test execution completed with some failures.')
  console.log('This is expected as we are fixing the tests one by one.')
}
