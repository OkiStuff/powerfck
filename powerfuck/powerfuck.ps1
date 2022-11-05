# Powerfuck PS1

# TODO:
# Implement Jumping

param(
	[Parameter()]
	[String]$filepath
)

enum Tokens
{
	IndexRight
	IndexLeft
	CellPlus
	CellMinus
	OutputChar
	InputChar
	JumpForwardIfZero
	JumpBackIfNotZero
}

function Parse
{
	[OutputType([Tokens[]])]
	param(
		[Parameter()] [String]$file
	)
	
	[Tokens[]]$tokens = @()
	
	for ([int]$i = 0; $i -lt $file.Length; $i++)
	{
		$tokens += switch($file[$i])
		{
			">" {[tokens]::IndexRight}
			"<" {[tokens]::IndexLeft}
			"+" {[tokens]::CellPlus}
			"-" {[tokens]::CellMinus}
			"." {[tokens]::OutputChar}
			"," {[tokens]::InputChar}
			"[" {[tokens]::JumpForwardIfZero}
			"]" {[tokens]::JumpBackIfNotZero}
		}
	}
	
	return $tokens
}

function Runtime
{
	[OutputType([Boolean])]
	param(
		[Parameter()] [Tokens[]]$tokens
	)
	
	[int]$stack_index = 0
	[int[]]$stack = @(0)
	
	[Boolean]$jump_flag = $false
	[System.Collections.ArrayList]$jump_indexes = @()
	
	for ([int]$i = 0; $i -lt $tokens.length; $i++)
	{	
	
		if ($jump_flag -eq $true)
		{
			if ($tokens[$i] -eq "JumpBackIfNotZero")
			{
				$jump_flag = $false
				$jump_indexes.removeAt($jump_indexes.Count - 1)
			}
			
			continue
		}
	
		switch($tokens[$i])
		{
			IndexRight
			{
				$stack_index++
				
				if ($stack_index -eq $stack.length)
				{
					$stack += 0 # Create new slot in stack
				}
			}
			
			IndexLeft
			{
				if ($stack_index -gt 0)
				{
					$stack_index--
				}
			}
			
			CellPlus
			{
				$stack[$stack_index]++
			}
			
			CellMinus
			{
				$stack[$stack_index]--
			}
			
			OutputChar
			{
				[char]$output = $stack[$stack_index]
				Write-Host -NoNewLine $output
			}
			
			InputChar
			{
				# Try catch is because powershell will not stop the script if input.length is > 1, will give error msg tho 
				try
				{
					[char]$char = Read-Host
				}
				
				catch [System.Management.Automation.RuntimeException]
				{
					Write-Host "quitting... char input length greater than one / invalid user input"
					exit
				}
				
				$stack[$stack_index] = $char
			}
			
			JumpForwardIfZero
			{
				[void]($jump_indexes.Add($i))
				
				if ($stack[$stack_index] -eq 0)
				{
					$jump_flag = $true
				}
			}
			
			JumpBackIfNotZero
			{
				if ($jump_indexes.Count -eq 0)
				{
					Write-Host "quitting... hanging ']'"
					exit
				}
				
				if ($stack[$stack_index] -ne 0)
				{
					$i = $jump_indexes[-1] - 1
				}
				
				$jump_indexes.removeAt($jump_indexes.Count - 1)# Remove the top tracked jump
			}
		}
	}
	
	return $true
}

function Interpreter
{
	[String]$file = Get-Content -Path $filepath
	[Tokens[]]$tokens = Parse $file
	
	[Boolean]$result = Runtime $tokens
}

Interpreter