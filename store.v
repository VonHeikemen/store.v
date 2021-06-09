import os
import json
import cli

const version_num = 'v0.1.1'

fn main() {
	mut app := cli.Command{
		name: 'store [document]'
		description: 'simple json based key-value pair database for your shell functions'
		usage: '[arguments]'
		disable_flags: true
	}

	query_cmd := cli.Command{
		name: 'query'
		description: 'Extract value from entry'
		usage: '<entry>'
		required_args: 2
		execute: fn (cmd cli.Command) ? {
			value := query(cmd.args[0], cmd.args[1]) or {
				eprintln(err)
				exit(1)
			}

			println(value)
		}
	}

	create_cmd := cli.Command{
		name: 'create'
		description: "creates an empty json file in your 'data folder'"
		usage: ' '
		required_args: 1
		execute: fn (cmd cli.Command) ? {
			create(cmd.args[0]) or {
				eprintln(err)
				exit(1)
			}

			println("'${cmd.args[0]}' created")
			return
		}
	}

	list_cmd := cli.Command{
		name: 'list'
		description: 'show all entries of a document'
		required_args: 1
		execute: fn (cmd cli.Command) ? {
			entries := list(cmd.args[0]) or {
				eprintln(err)
				exit(1)
			}

			print(entries)
		}
	}

	add_cmd := cli.Command{
		name: 'add'
		description: 'creates a new entry in the document'
		usage: '<entry> <value>'
		required_args: 3
		execute: fn (cmd cli.Command) ? {
			add(cmd.args[0], cmd.args[1], cmd.args[2]) or {
				eprintln(err)
				exit(1)
			}

			println("'${cmd.args[1]}' added")
		}
	}

	update_cmd := cli.Command{
		name: 'update'
		description: 'changes an entry in the document'
		usage: '<entry> <value>'
		required_args: 3
		execute: fn (cmd cli.Command) ? {
			old_value := update(cmd.args[0], cmd.args[1], cmd.args[2]) or {
				eprintln(err)
				exit(1)
			}

			println("'${cmd.args[1]}' updated")
			println('* from: $old_value')
			println('* to: ${cmd.args[2]}')
		}
	}

	remove_cmd := cli.Command{
		name: 'remove'
		description: 'deletes an entry from the document'
		usage: '<entry>'
		required_args: 2
		execute: fn (cmd cli.Command) ? {
			old_value := remove(cmd.args[0], cmd.args[1]) or {
				eprintln(err)
				exit(1)
			}

			println('removed')
			println('${cmd.args[1]}: $old_value')
		}
	}

	location_cmd := cli.Command{
		name: 'location'
		description: 'show file path to the document'
		required_args: 1
		execute: fn (cmd cli.Command) ? {
			path := get_document(cmd.args[0]) or {
				eprintln(err)
				exit(1)
			}

			println(path)
		}
	}

	version_cmd := cli.Command{
		name: 'version'
		description: 'Prints version information'
		execute: fn (cmd cli.Command) ? {
			println('store.v version $version_num')
		}
	}

	app.add_commands([
		create_cmd,
		query_cmd,
		list_cmd,
		add_cmd,
		update_cmd,
		remove_cmd,
		location_cmd,
		version_cmd,
	])
	app.setup()
	app.parse(get_args())
}

/**
 *  Commands
*/

fn query(document_id string, input string) ?string {
	entries := get_entries(document_id) ?
	value := entries[input] or { return error("Can't find '$input'") }

	return value
}

fn create(document_id string) ? {
	folder := get_data_folder() ?
	path := os.join_path(folder, '${document_id}.json')

	if os.is_file(path) {
		return error("'$document_id' already exists")
	}

	os.write_file(path, '{}') ?
}

fn list(id string) ?string {
	entries := get_entries(id) ?
	mut keys := ''

	for k, _ in entries {
		keys += k + '\n'
	}

	return keys
}

fn add(id string, entry string, value string) ? {
	mut entries := get_entries(id) ?

	if entry in entries {
		return error("'$entry' already exists")
	}

	entries[entry] = value

	replace_document(id, entries) ?
}

fn update(id string, entry string, value string) ?string {
	mut entries := get_entries(id) ?

	if entry !in entries {
		return error("'$entry' doesn't exists")
	}

	old_value := entries[entry]
	entries[entry] = value

	replace_document(id, entries) ?

	return old_value
}

fn remove(id string, entry string) ?string {
	mut entries := get_entries(id) ?

	if entry !in entries {
		return error("'$entry' doesn't exists")
	}

	mut new_entries := map[string]string{}
	mut old_value := ''

	for k, v in entries {
		if k == entry {
			old_value = v
		} else {
			new_entries[k] = v
		}
	}

	replace_document(id, new_entries) ?

	return old_value
}

/**
 * Utilities
*/

fn get_entries(document_id string) ?map[string]string {
	path := get_document(document_id) ?
	contents := os.read_file(path) ?

	entries := json.decode(map[string]string, contents) or {
		return error('File is not in valid json format.')
	}

	return entries
}

fn get_document(id string) ?string {
	data_folder := get_data_folder() ?
	document := os.join_path(data_folder, '${id}.json')

	if os.is_file(document) == false {
		return error('Invalid storage location')
	}

	return document
}

fn replace_document(document_id string, new_entries map[string]string) ? {
	path := get_document(document_id) ?
	backup := '${path}__backup'

	contents := json.encode_pretty(new_entries)

	os.cp(path, backup) ?
	os.write_file(path, contents) ?
	os.rm(backup) ?
}

fn get_data_folder() ?string {
	mut path := os.getenv('STORE_V_FOLDER')

	if path == '' {
		path = suggest_data_folder()

		if os.is_dir(path) == false {
			return error("Looks like you haven't setup your data folder.\nYou can set the environment variable STORE_V_FOLDER to an existing directory \nor create the directory $path")
		}
	}

	if os.is_dir(path) == false {
		return error('It looks like $path is not a valid directory')
	}

	return path
}

fn suggest_data_folder() string {
	$if windows {
		return os.join_path(os.home_dir(), 'AppData', 'Roaming', 'store-v', 'data')
	}

	$if macos {
		return os.join_path(os.home_dir(), 'Library', 'Application Support', 'com.vonheikemen.store-v',
			'data')
	}

	return os.join_path(os.home_dir(), '.config', 'store-v', 'data')
}

// rearrange the user's arguments because of my weird api design
fn get_args() []string {
	mut args := os.args.clone()
	special_cmd := ['help', 'version']

	id := os.args[1] or { 'help' }
	cmd := os.args[2] or { 'help' }

	if id in special_cmd {
		return args
	}

	if cmd in special_cmd {
		return [os.args[0], cmd]
	}

	args[1] = cmd
	args[2] = id

	return args
}
