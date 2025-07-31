# File: xml_to_sqlite.py
#
# Copyright (c) 2024 IC Verimeter. All rights reserved.
#
# Licensed under the MIT License.
#
# See LICENSE file in the project root for full license information.
#
# Description: Python script for converting IP-XACT XML files to SQLite database format.
#              Handles both IP-XACT and SPIRIT namespaces and preserves original XML content.
#              Provides comprehensive XML parsing, database schema management, and
#              detailed error reporting.

#!/usr/bin/env python3

import argparse
import os
import sqlite3
import xml.etree.ElementTree as ET
import hashlib
from datetime import datetime
import logging
from typing import Dict, List, Optional, Any

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Class: XMLToSQLite
#
# Converts IP-XACT XML files to SQLite database format.
# Handles both IP-XACT and SPIRIT namespaces and preserves original XML content.
# Provides comprehensive XML parsing, database schema management, and error reporting.
#
# The class supports:
# - Multiple XML file processing
# - Original XML content preservation
# - Detailed logging and error reporting
# - Schema validation and management
# - Support for both IP-XACT and SPIRIT namespaces
class XMLToSQLite:
    # Function: __init__
    #
    # Initialize the converter with database path and configuration.
    #
    # Parameters:
    #   db_path (str) - Path to the SQLite database file. The file will be created if it doesn't exist.
    #   debug (bool)  - Enable debug logging if True. When enabled, detailed debug information
    #                  will be logged about the conversion process.
    #
    # Example:
    #   converter = XMLToSQLite("output.db", debug=True)
    def __init__(self, db_path: str, debug: bool = False):
        """Initialize the converter with database path."""
        self.db_path = db_path
        self.conn = None
        self.cursor = None
        if debug:
            logger.setLevel(logging.DEBUG)
        self.namespaces = {
            'ipxact': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014',
            'spirit': 'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009',
            'kactus2': 'http://funbase.cs.tut.fi/'
        }

    # Function: connect
    #
    # Establish connection to SQLite database.
    # Creates a new database file if it doesn't exist.
    #
    # Raises:
    #   sqlite3.Error - If there are any database connection issues
    #
    # Example:
    #   try:
    #       converter.connect()
    #   except sqlite3.Error as e:
    #       print(f"Database connection failed: {e}")
    def connect(self):
        """Connect to SQLite database."""
        try:
            self.conn = sqlite3.connect(self.db_path)
            self.cursor = self.conn.cursor()
            logger.info(f"Connected to database: {self.db_path}")
        except sqlite3.Error as e:
            logger.error(f"Database connection error: {e}")
            raise

    # Function: close
    #
    # Close the database connection.
    # This method should be called after all database operations are complete
    # to properly release database resources.
    #
    # Example:
    #   converter.close()  # Always call this when done with the database
    def close(self):
        """Close database connection."""
        if self.conn:
            self.conn.close()
            logger.info("Database connection closed")

    # Function: create_tables
    #
    # Create database tables from schema.sql.
    # Drops existing tables if they exist to ensure a clean state.
    # The schema includes tables for:
    # - metadata: Component metadata and version information
    # - memoryMaps: Memory map definitions
    # - addressBlocks: Address block definitions
    # - registers: Register definitions
    # - fields: Field definitions within registers
    # - busInterfaces: Bus interface definitions
    # - ports: Port definitions
    # - parameters: Parameter definitions
    # - vendorExtensions: Vendor-specific extensions
    # - enumerations: Enumerated values for fields
    #
    # Raises:
    #   Exception - If there are any issues creating the tables
    #
    # Example:
    #   try:
    #       converter.create_tables()
    #   except Exception as e:
    #       print(f"Failed to create tables: {e}")
    def create_tables(self):
        """Create database tables from schema.sql."""
        try:
            import os
            schema_path = os.path.abspath('schema.sql')
            print(f"[DEBUG] Using schema file: {schema_path}")
            with open(schema_path, 'r') as f:
                schema_lines = f.readlines()
                print("[DEBUG] First 10 lines of schema.sql:")
                for line in schema_lines[:10]:
                    print(line.rstrip())
                schema = ''.join(schema_lines)
            # Drop existing tables if they exist
            self.cursor.executescript('''
                DROP TABLE IF EXISTS fields;
                DROP TABLE IF EXISTS registers;
                DROP TABLE IF EXISTS addressBlocks;
                DROP TABLE IF EXISTS memoryMaps;
                DROP TABLE IF EXISTS busInterfaces;
                DROP TABLE IF EXISTS ports;
                DROP TABLE IF EXISTS parameters;
                DROP TABLE IF EXISTS vendorExtensions;
                DROP TABLE IF EXISTS enumerations;
                DROP TABLE IF EXISTS metadata;
            ''')
            self.cursor.executescript(schema)
            self.conn.commit()
            logger.info("Database tables created successfully")
        except Exception as e:
            logger.error(f"Error creating tables: {e}")
            raise

    # Function: calculate_checksum
    #
    # Calculate MD5 checksum of a file.
    # Used to verify file integrity and detect changes.
    #
    # Parameters:
    #   file_path (str) - Path to the file to calculate checksum for
    #
    # Returns:
    #   str - MD5 checksum as hexadecimal string
    #
    # Example:
    #   checksum = converter.calculate_checksum("input.xml")
    #   print(f"File checksum: {checksum}")
    def calculate_checksum(self, file_path: str) -> str:
        """Calculate MD5 checksum of a file."""
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()

    # Function: get_text
    #
    # Get text content from XML element with namespace.
    # Handles both IP-XACT and SPIRIT namespaces.
    #
    # Parameters:
    #   element (ET.Element) - XML element to search in
    #   tag (str)           - Tag name to find
    #   namespace (str)     - Namespace prefix (default: 'spirit')
    #
    # Returns:
    #   Optional[str] - Text content if found, None otherwise
    #
    # Example:
    #   name = converter.get_text(element, 'name', 'spirit')
    #   if name:
    #       print(f"Found name: {name}")
    def get_text(self, element: ET.Element, tag: str, namespace: str = 'spirit') -> Optional[str]:
        """Get text content from XML element with namespace."""
        try:
            # Build namespace dictionary
            ns_dict = {'spirit': self.namespaces['spirit'], 'ipxact': self.namespaces['ipxact']}

            # Try direct child with namespace
            found_elem = element.find(f'./spirit:{tag}', ns_dict)

            # If not found with spirit namespace, try with ipxact namespace
            if found_elem is None:
                found_elem = element.find(f'./ipxact:{tag}', ns_dict)

            # If still not found, try without namespace prefix
            if found_elem is None:
                found_elem = element.find(f'./{tag}')

            if found_elem is None:
                logger.debug(f"Tag {tag} not found in element {element.tag}")
                return None

            text = found_elem.text
            logger.debug(f"Found tag {tag} with text: {text}")
            return text
        except (AttributeError, KeyError) as e:
            logger.debug(f"Error getting text for {tag}: {e}")
            return None

    # Function: insert_metadata
    #
    # Insert metadata into database.
    # Extracts and stores component metadata including vendor, library,
    # name, version, and description.
    #
    # Parameters:
    #   root (ET.Element) - Root XML element
    #   file_path (str)   - Path to source XML file
    #
    # Returns:
    #   int - ID of inserted metadata record
    #
    # Example:
    #   metadata_id = converter.insert_metadata(root, "input.xml")
    #   print(f"Inserted metadata with ID: {metadata_id}")
    def insert_metadata(self, root: ET.Element, file_path: str) -> int:
        """Insert metadata into database and return metadata_id."""
        vendor = self.get_text(root, 'vendor') or ''
        library = self.get_text(root, 'library') or ''
        name = self.get_text(root, 'name') or ''
        version = self.get_text(root, 'version') or ''
        description = self.get_text(root, 'description')

        # Determine namespace
        namespace = 'ipxact' if 'ipxact' in root.tag else 'spirit'

        # Get schema version
        schema_version = root.get('schemaVersion', '')

        # Calculate checksum
        checksum = self.calculate_checksum(file_path)

        # Insert metadata
        self.cursor.execute('''
            INSERT INTO metadata (
                vendor, library, name, version, description, namespace,
                schemaVersion, created, sourceFile, checksum
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            vendor, library, name, version, description, namespace,
            schema_version, datetime.now(), file_path, checksum
        ))

        self.conn.commit()
        return self.cursor.lastrowid

    # Function: store_original_xml
    #
    # Store original XML content to preserve formatting and structure.
    # This ensures that the original XML can be reconstructed exactly
    # when converting back from the database.
    #
    # Parameters:
    #   metadata_id (int) - ID of the metadata record
    #   file_path (str)   - Path to source XML file
    #
    # Returns:
    #   bool - True if successful, False otherwise
    #
    # Example:
    #   success = converter.store_original_xml(metadata_id, "input.xml")
    #   if success:
    #       print("Original XML stored successfully")
    def store_original_xml(self, metadata_id: int, file_path: str):
        """Store the original XML content to preserve formatting, comments, and structure."""
        try:
            # Read the original XML file
            with open(file_path, 'r', encoding='utf-8') as f:
                xml_content = f.read()

            # Get file modification time
            last_modified = datetime.fromtimestamp(os.path.getmtime(file_path))

            # Calculate checksum
            checksum = self.calculate_checksum(file_path)

            # Store in the original_xml table
            self.cursor.execute('''
                INSERT INTO original_xml (
                    metadata_id, xml_content, file_path, last_modified, checksum
                ) VALUES (?, ?, ?, ?, ?)
            ''', (metadata_id, xml_content, file_path, last_modified, checksum))

            self.conn.commit()
            logger.info(f"Stored original XML content for metadata_id {metadata_id}")
            return True
        except Exception as e:
            logger.error(f"Error storing original XML content: {e}")
            self.conn.rollback()
            return False

    # Function: insert_memory_maps
    #
    # Insert memory maps into database.
    #
    # Parameters: root       - Root XML element
    #           metadata_id - ID of the metadata record
    def insert_memory_maps(self, root: ET.Element, metadata_id: int):
        """Insert memory maps into database."""
        memory_maps = root.findall('.//{*}memoryMap')
        if not memory_maps:
            logger.info("No memory maps found in the XML file")
            return

        for mm in memory_maps:
            name = self.get_text(mm, 'name') or ''
            description = self.get_text(mm, 'description')

            self.cursor.execute('''
                INSERT INTO memoryMaps (
                    metadata_id, name, description
                ) VALUES (?, ?, ?)
            ''', (metadata_id, name, description))

            mm_id = self.cursor.lastrowid

            # Process address blocks
            self.insert_address_blocks(mm, mm_id)

    # Function: insert_address_blocks
    #
    # Insert address blocks into database.
    #
    # Parameters: memory_map - Memory map XML element
    #           memory_map_id - ID of the memory map
    def insert_address_blocks(self, memory_map: ET.Element, memory_map_id: int):
        """Insert address blocks into database."""
        address_blocks = memory_map.findall('.//{*}addressBlock')
        if not address_blocks:
            logger.info(f"No address blocks found in memory map ID {memory_map_id}")
            return

        for ab in address_blocks:
            name = self.get_text(ab, 'name') or ''
            description = self.get_text(ab, 'description')
            base_address = self.get_text(ab, 'baseAddress') or '0'
            range_val = self.get_text(ab, 'range') or '0'
            width = None
            width_text = self.get_text(ab, 'width')
            if width_text:
                try:
                    width = int(width_text)
                except ValueError:
                    logger.warning(f"Invalid width value: {width_text}, using NULL")
            else:
                width = 32  # Default value

            usage = self.get_text(ab, 'usage')

            self.cursor.execute('''
                INSERT INTO addressBlocks (
                    memoryMap_id, name, description, baseAddress,
                    range, width, usage
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                memory_map_id, name, description, base_address,
                range_val, width, usage
            ))

            ab_id = self.cursor.lastrowid

            # Process registers
            self.insert_registers(ab, ab_id)

    # Function: insert_registers
    #
    # Insert registers into database.
    #
    # Parameters: address_block - Address block XML element
    #           address_block_id - ID of the address block
    def insert_registers(self, address_block: ET.Element, address_block_id: int):
        """Insert registers into database."""
        # Find registers with explicit namespace
        ns_dict = {'spirit': self.namespaces['spirit'], 'ipxact': self.namespaces['ipxact']}
        registers = address_block.findall('./spirit:register', ns_dict)

        if not registers:
            # Try alternate approach
            registers = address_block.findall('.//{*}register')

        if not registers:
            logger.info(f"No registers found in address block ID {address_block_id}")
            return

        for reg in registers:
            logger.debug(f"Processing register: {ET.tostring(reg, encoding='unicode')[:100]}...")
            name = self.get_text(reg, 'name') or ''
            logger.debug(f"Register name: {name}")
            description = self.get_text(reg, 'description')
            address_offset = self.get_text(reg, 'addressOffset') or '0'

            size = None
            size_text = self.get_text(reg, 'size')
            if size_text:
                try:
                    size = int(size_text)
                except ValueError:
                    logger.warning(f"Invalid size value: {size_text}, using NULL")
            else:
                size = 32  # Default value

            access = self.get_text(reg, 'access')
            if access not in ('read-only', 'write-only', 'read-write', 'writeOnce', 'read-writeOnce', None):
                logger.warning(f"Invalid access value: {access}, using NULL")
                access = None

            volatile_text = self.get_text(reg, 'volatile')
            volatile = None
            if volatile_text is not None:
                volatile = volatile_text.lower() == 'true'

            # Extract reset value and mask from register
            resetValue = None
            resetMask = None
            reset = reg.find('.//{*}reset')
            if reset is not None:
                reset_value_elem = reset.find('.//{*}value')
                if reset_value_elem is not None and reset_value_elem.text:
                    resetValue = reset_value_elem.text

                reset_mask_elem = reset.find('.//{*}mask')
                if reset_mask_elem is not None and reset_mask_elem.text:
                    resetMask = reset_mask_elem.text

            # Set UVM-specific defaults
            rand = False  # Default to False

            logger.debug(f"Inserting register: name={name}, offset={address_offset}, size={size}, access={access}, resetValue={resetValue}, resetMask={resetMask}")
            self.cursor.execute('''
                INSERT INTO registers (
                    addressBlock_id, name, description, addressOffset,
                    size, access, volatile, resetValue, resetMask, rand
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                address_block_id, name, description, address_offset,
                size, access, volatile, resetValue, resetMask, rand
            ))

            reg_id = self.cursor.lastrowid
            logger.debug(f"Inserted register with ID: {reg_id}")
            # Process vendor extensions for this register
            vendor_extensions = reg.find('.//{*}vendorExtensions')
            if vendor_extensions is not None:
                for extension in vendor_extensions:
                    if not isinstance(extension, ET.Element):
                        continue
                    vendor_id = 'unknown'
                    if '}' in extension.tag:
                        try:
                            vendor_id = extension.tag.split('}')[0].strip('{')
                        except Exception:
                            logger.warning(f"Could not extract vendor ID from tag: {extension.tag}")
                    tag_name = extension.tag.split('}')[-1] if '}' in extension.tag else extension.tag
                    # Key encodes register name for round-trip
                    key = f"register:{name}:{tag_name}"
                    try:
                        if extension.text and not list(extension):
                            value = extension.text
                        else:
                            value = ET.tostring(extension, encoding='unicode')
                    except Exception as e:
                        logger.warning(f"Error processing vendor extension: {e}")
                        value = ''
                    # Use the metadata_id from the parent component
                    # Find metadata_id by traversing up the parent chain
                    # (address_block -> memory_map -> component)
                    # But here, pass it as an argument or store it in self if needed
                    # For now, assume self.current_metadata_id is set during processing
                    self.cursor.execute('''
                        INSERT INTO vendorExtensions (
                            metadata_id, vendorId, key, value
                        ) VALUES (?, ?, ?, ?)
                    ''', (self.current_metadata_id, vendor_id, key, value))

            # Process fields
            self.insert_fields(reg, reg_id)

    # Function: insert_fields
    #
    # Insert fields into database.
    #
    # Parameters: register - Register XML element
    #           register_id - ID of the register
    def insert_fields(self, register: ET.Element, register_id: int):
        """Insert fields into database."""
        # Find fields with explicit namespace
        ns_dict = {'spirit': self.namespaces['spirit'], 'ipxact': self.namespaces['ipxact']}
        fields = register.findall('./spirit:field', ns_dict)

        if not fields:
            # Try alternate approach
            fields = register.findall('.//{*}field')

        if not fields:
            logger.info(f"No fields found in register ID {register_id}")
            return

        for field in fields:
            logger.debug(f"Processing field: {ET.tostring(field, encoding='unicode')[:100]}...")
            # Extract all possible columns from the schema
            name = self.get_text(field, 'name') or ''
            logger.debug(f"Field name: {name}")
            description = self.get_text(field, 'description')
            displayName = self.get_text(field, 'displayName')

            # Handle required numeric fields
            bitOffset = None
            bitOffset_text = self.get_text(field, 'bitOffset')
            if bitOffset_text:
                try:
                    bitOffset = int(bitOffset_text)
                except ValueError:
                    logger.warning(f"Invalid bitOffset value: {bitOffset_text}, using NULL")

            bitWidth = None
            bitWidth_text = self.get_text(field, 'bitWidth')
            if bitWidth_text:
                try:
                    bitWidth = int(bitWidth_text)
                except ValueError:
                    logger.warning(f"Invalid bitWidth value: {bitWidth_text}, using NULL")

            access = self.get_text(field, 'access')
            if access not in ('read-only', 'write-only', 'read-write', 'writeOnce', 'read-writeOnce', None):
                logger.warning(f"Invalid access value: {access}, using NULL")
                access = None

            logger.debug(f"Inserting field: name={name}, bitOffset={bitOffset}, bitWidth={bitWidth}, access={access}")

            resetTypeRef = self.get_text(field, 'resetTypeRef')
            resetTrigger = self.get_text(field, 'resetTrigger')
            resetPolarity = self.get_text(field, 'resetPolarity')
            resetSynchronization = self.get_text(field, 'resetSynchronization')
            resetDomain = self.get_text(field, 'resetDomain')
            resetDependency = self.get_text(field, 'resetDependency')
            resetSequence = self.get_text(field, 'resetSequence')
            resetMask = None

            # Get reset value if exists
            resetValue = None
            reset = field.find('.//{*}reset')
            if reset is not None:
                resetValue = self.get_text(reset, 'value')
                resetMask = self.get_text(reset, 'mask')

            # Convert boolean values
            isVolatile = None
            isVolatile_text = self.get_text(field, 'volatile')
            if isVolatile_text is not None:
                isVolatile = isVolatile_text.lower() == 'true'

            isReserved = None
            isReserved_text = self.get_text(field, 'reserved')
            if isReserved_text is not None:
                isReserved = isReserved_text.lower() == 'true'

            modifiedWriteValue = self.get_text(field, 'modifiedWriteValue')
            readAction = self.get_text(field, 'readAction')
            writeValueConstraint = self.get_text(field, 'writeValueConstraint')
            testable = self.get_text(field, 'testable')
            isPresent = self.get_text(field, 'isPresent')
            dependence = self.get_text(field, 'dependence')
            typeIdentifier = self.get_text(field, 'typeIdentifier')
            enumValuesRef = self.get_text(field, 'enumValuesRef')
            longDescription = self.get_text(field, 'longDescription')
            groupName = self.get_text(field, 'groupName')
            displayGroup = self.get_text(field, 'displayGroup')
            alternateGroups = self.get_text(field, 'alternateGroups')
            usage = self.get_text(field, 'usage')
            enumName = self.get_text(field, 'enumName')
            enumValue = self.get_text(field, 'enumValue')
            enumDisplayName = self.get_text(field, 'enumDisplayName')

            # Set UVM-specific defaults
            rand = False  # Default to False
            mirror = 0  # Default to 0 (integer)
            volatile = isVolatile  # Use the same value as isVolatile

            self.cursor.execute('''
                INSERT INTO fields (
                    register_id, name, description, displayName, bitOffset, bitWidth, access, resetValue, resetTypeRef, resetTrigger, resetPolarity, resetSynchronization, resetDomain, resetDependency, resetSequence, resetMask, isVolatile, isReserved, modifiedWriteValue, readAction, writeValueConstraint, testable, isPresent, dependence, typeIdentifier, enumValuesRef, longDescription, groupName, displayGroup, alternateGroups, usage, enumName, enumValue, enumDisplayName, rand, mirror, volatile
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                register_id, name, description, displayName, bitOffset, bitWidth, access, resetValue, resetTypeRef, resetTrigger, resetPolarity, resetSynchronization, resetDomain, resetDependency, resetSequence, resetMask, isVolatile, isReserved, modifiedWriteValue, readAction, writeValueConstraint, testable, isPresent, dependence, typeIdentifier, enumValuesRef, longDescription, groupName, displayGroup, alternateGroups, usage, enumName, enumValue, enumDisplayName, rand, mirror, volatile
            ))

            # Process enumerations if they exist
            self.insert_enumerations(field, self.cursor.lastrowid)

    # Function: insert_bus_interfaces
    #
    # Insert bus interfaces into database.
    #
    # Parameters: root       - Root XML element
    #           metadata_id - ID of the metadata record
    def insert_bus_interfaces(self, root: ET.Element, metadata_id: int):
        """Insert bus interfaces into database."""
        bus_interfaces = root.findall('.//{*}busInterface')
        if not bus_interfaces:
            logger.info("No bus interfaces found in the XML file")
            return

        for bi in bus_interfaces:
            name = self.get_text(bi, 'name') or ''
            bus_type = ''

            # Get busType
            bus_type_elem = bi.find('.//{*}busType')
            if bus_type_elem is not None:
                vendor = bus_type_elem.get('vendor', '')
                library = bus_type_elem.get('library', '')
                name_attr = bus_type_elem.get('name', '')
                version = bus_type_elem.get('version', '')
                bus_type = f"{vendor}:{library}:{name_attr}:{version}"

            abstraction_type = ''
            # Get abstractionType
            abstraction_type_elem = bi.find('.//{*}abstractionType')
            if abstraction_type_elem is not None:
                vendor = abstraction_type_elem.get('vendor', '')
                library = abstraction_type_elem.get('library', '')
                name_attr = abstraction_type_elem.get('name', '')
                version = abstraction_type_elem.get('version', '')
                abstraction_type = f"{vendor}:{library}:{name_attr}:{version}"

            interface_mode = self.get_text(bi, 'interfaceMode')
            if interface_mode not in ('master', 'slave', 'system', None):
                logger.warning(f"Invalid interfaceMode value: {interface_mode}, using NULL")
                interface_mode = None

            display_name = self.get_text(bi, 'displayName')
            is_present = self.get_text(bi, 'isPresent')
            initiative = self.get_text(bi, 'initiative')

            self.cursor.execute('''
                INSERT INTO busInterfaces (
                    metadata_id, name, busType, abstractionType, interfaceMode,
                    displayName, isPresent, initiative
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                metadata_id, name, bus_type, abstraction_type, interface_mode,
                display_name, is_present, initiative
            ))

    # Function: insert_ports
    #
    # Insert ports into database.
    #
    # Parameters: root       - Root XML element
    #           metadata_id - ID of the metadata record
    def insert_ports(self, root: ET.Element, metadata_id: int):
        """Insert ports into database."""
        ports = root.findall('.//{*}port')
        if not ports:
            logger.info("No ports found in the XML file")
            return

        # Extract parameters first to resolve parameter references in vectors
        parameters = {}
        for param in root.findall('.//{*}parameter'):
            param_id = param.get('parameterId')
            if param_id:
                param_name = self.get_text(param, 'name')
                param_value = self.get_text(param, 'value')
                if param_name and param_value:
                    parameters[param_id] = param_value
                    logger.debug(f"Found parameter: {param_id} = {param_name} = {param_value}")

        for port in ports:
            name = self.get_text(port, 'name') or ''
            description = self.get_text(port, 'description')

            # Get direction from wire element
            direction = None
            wire = port.find('.//{*}wire')
            if wire is not None:
                # Try to get direction from wire element
                direction_elem = wire.find('.//{*}direction')
                if direction_elem is not None and direction_elem.text:
                    direction = direction_elem.text
                else:
                    # Try using get_text on wire element
                    direction = self.get_text(wire, 'direction')

            # If direction is still None, try the old way
            if direction is None:
                direction = self.get_text(port, 'direction')

            # If we still don't have a direction, use a default
            if direction is None:
                logger.warning(f"No direction found for port {name}, using 'in' as default")
                direction = 'in'

            # Handle boolean values
            is_address = None
            is_address_text = self.get_text(port, 'isAddress')
            if is_address_text is not None:
                is_address = is_address_text.lower() == 'true'

            is_data = None
            is_data_text = self.get_text(port, 'isData')
            if is_data_text is not None:
                is_data = is_data_text.lower() == 'true'

            # Get width
            width = None
            if wire is not None:
                vector = wire.find('.//{*}vector')
                if vector is not None:
                    left = self.get_text(vector, 'left')
                    right = self.get_text(vector, 'right')
                    if left is not None and right is not None:
                        try:
                            # Try direct conversion to integers
                            left_val = int(left)
                            right_val = int(right)
                            width = abs(left_val - right_val) + 1
                        except ValueError:
                            # Check if bounds are parameter references (UUIDs)
                            try:
                                # Extract UUID from left value if it's a parameter reference
                                if 'uuid_' in left:
                                    uuid_part = left.split('-')[0]  # Remove the "-1" suffix if present
                                    if uuid_part in parameters:
                                        left_param_value = parameters[uuid_part]
                                        left_val = int(left_param_value)
                                        if '-' in left:  # If format is "uuid-1", subtract 1
                                            left_val = left_val - 1
                                    else:
                                        logger.warning(f"Parameter reference not found: {uuid_part}")
                                        left_val = 0
                                else:
                                    left_val = 0

                                # Right value is typically 0
                                if 'uuid_' in right:
                                    uuid_part = right.split('-')[0]
                                    if uuid_part in parameters:
                                        right_val = int(parameters[uuid_part])
                                    else:
                                        right_val = 0
                                else:
                                    right_val = int(right)

                                width = abs(left_val - right_val) + 1
                                logger.debug(f"Resolved parameter reference for port {name}: width={width}")
                            except Exception as e:
                                logger.warning(f"Invalid vector bounds for port {name}: left={left}, right={right}, error={e}")

            display_name = self.get_text(port, 'displayName')

            logger.debug(f"Inserting port: name={name}, direction={direction}, width={width}")

            self.cursor.execute('''
                INSERT INTO ports (
                    metadata_id, name, description, direction, isAddress,
                    isData, width, displayName
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                metadata_id, name, description, direction, is_address,
                is_data, width, display_name
            ))

    # Function: insert_parameters
    #
    # Insert parameters into database.
    #
    # Parameters: root       - Root XML element
    #           metadata_id - ID of the metadata record
    def insert_parameters(self, root: ET.Element, metadata_id: int):
        """Insert parameters into database."""
        parameters = root.findall('.//{*}parameter')
        if not parameters:
            logger.info("No parameters found in the XML file")
            return

        for param in parameters:
            name = self.get_text(param, 'name') or ''
            display_name = self.get_text(param, 'displayName')
            value = self.get_text(param, 'value')
            description = self.get_text(param, 'description')
            data_type = self.get_text(param, 'dataType') or 'string'

            # Determine if component parameter or other scope
            scope = 'component'
            try:
                parent = param.getparent()
                if parent is not None:
                    parent_tag = parent.tag.split('}')[-1]
                    if parent_tag != 'component':
                        scope = parent_tag
            except AttributeError:
                # ElementTree in standard library doesn't have getparent()
                # Just use default scope
                pass

            self.cursor.execute('''
                INSERT INTO parameters (
                    metadata_id, name, displayName, value, description,
                    type, scope
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                metadata_id, name, display_name, value, description,
                data_type, scope
            ))

    # Function: insert_vendor_extensions
    #
    # Insert vendor extensions into database.
    #
    # Parameters: root       - Root XML element
    #           metadata_id - ID of the metadata record
    def insert_vendor_extensions(self, root: ET.Element, metadata_id: int):
        """Insert vendor extensions into database."""
        vendor_extensions = root.find('.//{*}vendorExtensions')
        if vendor_extensions is None:
            logger.info("No vendor extensions found in the XML file")
            return

        # Process all child elements
        for extension in vendor_extensions:
            # Skip text nodes
            if not isinstance(extension, ET.Element):
                continue

            # Extract vendor ID from namespace or tag
            vendor_id = 'unknown'
            if '}' in extension.tag:
                try:
                    vendor_id = extension.tag.split('}')[0].strip('{')
                except Exception:
                    logger.warning(f"Could not extract vendor ID from tag: {extension.tag}")

            # Use tag name as the key
            tag_name = extension.tag.split('}')[-1] if '}' in extension.tag else extension.tag

            # Extension value could be text or XML structure
            value = None
            try:
                if extension.text and not list(extension):  # No children
                    value = extension.text
                else:
                    # Convert complex structure to string
                    value = ET.tostring(extension, encoding='unicode')
            except Exception as e:
                logger.warning(f"Error processing vendor extension: {e}")

            self.cursor.execute('''
                INSERT INTO vendorExtensions (
                    metadata_id, vendorId, key, value
                ) VALUES (?, ?, ?, ?)
            ''', (metadata_id, vendor_id, tag_name, value))

    # Function: insert_enumerations
    #
    # Insert enumerations into database.
    #
    # Parameters: field    - Field XML element
    #           field_id - ID of the field
    def insert_enumerations(self, field: ET.Element, field_id: int):
        """Insert enumerations into database."""
        enumerations = field.findall('.//{*}enumeratedValue')
        if not enumerations:
            return  # Not logging as many fields don't have enumerations

        for enum in enumerations:
            name = self.get_text(enum, 'name') or ''
            value = self.get_text(enum, 'value')
            display_name = self.get_text(enum, 'displayName')
            description = self.get_text(enum, 'description')
            usage = self.get_text(enum, 'usage')

            self.cursor.execute('''
                INSERT INTO enumerations (
                    field_id, name, value, displayName, description, usage
                ) VALUES (?, ?, ?, ?, ?, ?)
            ''', (field_id, name, value, display_name, description, usage))

    # Function: process_xml_file
    #
    # Process XML file and convert to SQLite database.
    #
    # Parameters: xml_file - Path to input XML file
    def process_xml_file(self, xml_file: str):
        """Process a single XML file and insert its data into the database."""
        try:
            logger.info(f"Processing XML file: {xml_file}")

            # Read the XML content
            with open(xml_file, 'r', encoding='utf-8') as f:
                xml_content = f.read()

            # Find all component elements in the file
            # Look for both spirit and ipxact namespaces
            spirit_components = self._extract_components(xml_content, 'spirit:component')
            ipxact_components = self._extract_components(xml_content, 'ipxact:component')

            # Combine all found components
            all_components = spirit_components + ipxact_components

            if not all_components:
                logger.warning(f"No component elements found in {xml_file}")
                return

            logger.info(f"Found {len(all_components)} component(s) in {xml_file}")

            # Process each component
            for i, component_xml in enumerate(all_components):
                try:
                    # Parse the component XML
                    component_root = ET.fromstring(component_xml)

                    # Insert metadata and get metadata_id
                    component_name = self.get_text(component_root, 'name') or f"component_{i}"
                    logger.info(f"Processing component: {component_name} ({i+1}/{len(all_components)})")

                    metadata_id = self.insert_metadata(component_root, xml_file)

                    # Store the original XML content
                    self.store_original_xml(metadata_id, xml_file)

                    # Process memory maps
                    # Set current_metadata_id for use in register/addressBlock vendorExtensions
                    self.current_metadata_id = metadata_id
                    self.insert_memory_maps(component_root, metadata_id)
                    del self.current_metadata_id

                    # Process bus interfaces
                    self.insert_bus_interfaces(component_root, metadata_id)

                    # Process ports
                    self.insert_ports(component_root, metadata_id)

                    # Process parameters
                    self.insert_parameters(component_root, metadata_id)

                    # Process vendor extensions
                    self.insert_vendor_extensions(component_root, metadata_id)

                    self.conn.commit()
                    logger.info(f"Successfully processed component {i+1}/{len(all_components)}: {component_name}")

                except Exception as e:
                    logger.error(f"Error processing component {i+1}/{len(all_components)}: {e}")
                    self.conn.rollback()

            logger.info(f"Successfully processed {xml_file}")

        except Exception as e:
            logger.error(f"Error processing {xml_file}: {e}")
            self.conn.rollback()
            raise

    # Function: _extract_components
    #
    # Extract component elements from XML content.
    #
    # Parameters: xml_content - XML content as string
    #           component_tag - Component tag name
    # Returns: List of component elements
    def _extract_components(self, xml_content: str, component_tag: str) -> list:
        """Extract component XML sections from the content.

        Args:
            xml_content: The full XML content
            component_tag: The component tag to search for (e.g., 'spirit:component' or 'ipxact:component')

        Returns:
            List of XML strings, each containing a complete component element
        """
        components = []

        # Find all start positions of component tags
        start_tag = f"<{component_tag}"
        end_tag = f"</{component_tag}>"

        start_pos = 0
        while True:
            start_pos = xml_content.find(start_tag, start_pos)
            if start_pos == -1:
                break

            # Find the matching end tag
            end_pos = xml_content.find(end_tag, start_pos)
            if end_pos == -1:
                logger.warning(f"Found start tag {start_tag} but no matching end tag")
                break

            # Extract the component XML including the end tag
            component_xml = xml_content[start_pos:end_pos + len(end_tag)]
            components.append(component_xml)

            # Move past this component for the next search
            start_pos = end_pos + len(end_tag)

        return components

# Function: main
#
# Main entry point for the script.
# Parses command line arguments and processes XML files.
#
# Command line arguments:
#   xml_file - Input XML file (optional if -f is used)
#   -f, --file-list - File containing list of XML files to process
#   -o, --output - Output SQLite database path (required)
#   -d, --debug - Enable debug logging
#
# Example usage:
#   python xml_to_sqlite.py input.xml -o output.db
#   python xml_to_sqlite.py -f file_list.txt -o output.db -d
def main():
    parser = argparse.ArgumentParser(description='Convert IP-XACT XML files to SQLite database')
    parser.add_argument('xml_file', nargs='?', help='Input XML file')
    parser.add_argument('-f', '--file-list', help='File containing list of XML files to process')
    parser.add_argument('-o', '--output', required=True, help='Output SQLite database path')
    parser.add_argument('-d', '--debug', action='store_true', help='Enable debug logging')

    args = parser.parse_args()

    if not args.xml_file and not args.file_list:
        parser.error("Either an XML file or a file list (-f) must be provided")

    converter = XMLToSQLite(args.output, args.debug)

    try:
        converter.connect()
        converter.create_tables()

        if args.file_list:
            with open(args.file_list, 'r') as f:
                xml_files = [line.strip() for line in f if line.strip()]
            for xml_file in xml_files:
                if os.path.exists(xml_file):
                    converter.process_xml_file(xml_file)
                else:
                    logger.warning(f"File not found: {xml_file}")
        else:
            converter.process_xml_file(args.xml_file)

    except Exception as e:
        logger.error(f"Error: {e}")
    finally:
        converter.close()

if __name__ == '__main__':
    main()